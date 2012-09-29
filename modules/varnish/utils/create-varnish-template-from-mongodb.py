#!/usr/bin/python

# This script can be run on a mongodb machine and will connect to the router-dev
# database. From that database, it will generate an erb template on stdout.


import re
from pymongo import Connection
connection = Connection()
db = connection['router-dev']
print "# Backends" 
applications = db.applications
for application in applications.find():
  if application['application_id'] == "frontend":
     host_header = "www.<%= govuk_platform %>.alphagov.co.uk"
  elif application['application_id'] == "whitehall":
     host_header = "whitehall-frontend.<%= govuk_platform %>.alphagov.co.uk"
  else:
     host_header = "%s.<%%= govuk_platform %%>.alphagov.co.uk" % application['application_id']
  if application['application_id'] != "router-gone" and application['application_id'] != "router-redirect":
    print 
    print "backend %s {" % application['application_id']
    print "  .host = '%s';" % host_header 
    print "  .port = '80';"
    print "  .host_header = '%s';" %host_header
    print "}"
print

print 'acl purge_acl {'
print '  "localhost";'
print '}'
print ''
print 'sub vcl_recv {'
print "  # Listing Routes"
print " ",
routes = db.routes
for application in applications.find():
  route_query = {}
  route_query["application_id"] = application['application_id']
  if application['application_id'] != "whitehall" and application['application_id'] != "frontend" and application['application_id'] != "router-gone" and application['application_id'] != "router-redirect":
    paths = []
    for route in routes.find(route_query):
      if not ( re.match('.*json$',route['incoming_path']) and ( route['application_id'] == "smartanswers" or route['application_id'] == "calendars")) :
        if route['route_type'] != "prefix":
          url = '^/%s$' % route['incoming_path']
        else:
          url = '^/%s' % route['incoming_path']
        paths.append(url)
    print "if (req.url ~ \"%s\") {" % "|".join(paths)
    print "    set req.backend = %s;" % application['application_id']
    print "  } else",
print "{"
print "  set req.backend = frontend;"
print "}"
print """

  if (req.url ~ "(.+)/$") {
    set req.http.x-Redir-Url = regsub(req.url, "^(.+)/$", "\1");
    error 667 req.http.x-Redir-Url;
  }

  # normalize Accept-Encoding header
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpeg|jpg|png|gif|gz|tgz|bz2|tbz|zip|flv|pdf|mp3|ogg)$") {
      remove req.http.Accept-Encoding; # already compressed
    }
    elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    }
    elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    }
    else {
      remove req.http.Accept-Encoding;
    }
  }

  # Serve stale period
  set req.grace = 6h;

  # remove cookies
  unset req.http.cookie;

  # purge individual URLs from the cache
  if(req.request == "PURGE") {
    if(!client.ip ~ purge_acl) {
      error 405 "Not allowed";
    } else {
<% if scope.lookupvar('varnish::varnish_version') == 3 %>
      ban("req.url == " + req.url);
<% else %>
      purge("req.url == " req.url);
<% end %>
      error 200 "Purged";
    }
  }

  # don't cache post requests
  if (req.request == "POST") {
    return(pass);
  }

  # allow http auth reqests
  if (req.http.Authorization) {
    return(lookup);
  }

  # Ignore cookies for caching purposes
  if (req.request == "GET" && req.http.cookie) {
    return(lookup);
  }
}

sub vcl_fetch {
  # remove cookies
  unset beresp.http.set-cookie;

  # hide some internal headers
  unset beresp.http.X-XSS-Protection;
  unset beresp.http.X-Slimmer-Section;
  unset beresp.http.X-Slimmer-Proposition;
  unset beresp.http.X-Slimmer-Template;
  unset beresp.http.X-Rack-Cache;
  unset beresp.http.X-Runtime;

<% if scope.lookupvar('varnish::varnish_version') == 3 %>
  if (beresp.ttl > 0s) {
<% else %>
  if (beresp.cacheable) {
<% end %>
    # Remove Expires from backend, it's not long enough
    unset beresp.http.expires;

    # Set how long Varnish will keep it
    set beresp.ttl = <%= scope.lookupvar('varnish::default_ttl') %>s;

    # marker for vcl_deliver to reset Age
    set beresp.http.magicmarker = "1";
  }

  # if we get a 503 error then server stale content
  if (beresp.status >= 503 && beresp.status <= 504) {
    set beresp.saintmode = 5m;
    if (req.restarts > 0) {
      return(restart);
    }
  }

  # Serve stale period
  set beresp.grace = 6h;

  # Allow cached authorized requests
  if (req.http.Authorization) {
    return(deliver);
  }

  # Ignore cookies for caching purposes
  if (beresp.http.Set-Cookie) {
    return(deliver);
  }
}

sub vcl_hash {
<% if scope.lookupvar('varnish::varnish_version') == 3 %>
  hash_data(req.url);
<% else %>
  set req.hash += req.url;
<% end %>
  return(hash);
}

sub vcl_deliver {
  if (resp.http.magicmarker) {
    # Remove the magic marker
    unset resp.http.magicmarker;

    # By definition we have a fresh object
    set resp.http.age = "0";
  }

  # Add a custom header to indicate whether we hit the cache or not
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
}

sub vcl_error {
  # 667 errors are our internal "redirect wanted" errors
  # They're raised in vcl_recv.
  if (obj.status == 667) {
    set obj.http.Location = obj.response;
    set obj.status = 301;
    return(deliver);
  }
}
"""
