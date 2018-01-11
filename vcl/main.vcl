#
# NOTE: The order of these includes is extremely important.
#

# Support the querystring manipulation functions.
import querystring;

# The Fastly VCL boilerplate.
include "fastly-boilerplate-begin.vcl";

# Use `req.http.Fastly-FF` conditions to ensure logic is run only once at the shield, negate for at the edge.

sub vcl_recv {
  # Save the request's URL and host before we modify it.
  if (!req.http.Fastly-FF) {
    set req.http.Original-Url = req.url;
    set req.http.Original-Host = req.http.Host;
  }

  if (!req.http.Fastly-SSL) {
		# 801 is a special error code that Fastly uses to Force SSL on the request
		error 801 "Redirect to prod HTTPS";
	}

  # Table is stored in a VCL snippet which can be viewed via the Fastly UI.
  if (req.http.FT-Origami-Key != table.lookup(secrets, "FT-Origami-Key")) {
    error 901 "Invalid key";
  }

  #
  # TODO: Uncomment this when the ACLs are added to our Fastly service by the FT Tooling team
  #
  # Deny requests from the managed blacklist of IP addresses.
  # if (req.http.Fastly-Client-IP ~ ft_manage_blacklist) {
  #   error 403 "Forbidden";
  # }
  #
  # Skip WAF for requests from the managed whitelist of IP addresses.
  # set req.http.bypass_waf = if(req.http.Fastly-Client-IP ~ FT_Internal_IP_Whitelist, "1", "0");
}

sub vcl_deliver {
  set resp.http.FT-Suppress-Friendly-Error = "true";
  # CORS headers needed in order to make response status known to fetch requests (service workers)
  if (req.http.Origin) {
    set resp.http.Access-Control-Allow-Origin = req.http.Origin;

    if (req.request == "OPTIONS") {
      set resp.http.Cache-Control = "max-age=604800, must-revalidate";
    }
  }

  if (!resp.http.Vary:Origin) {
    set resp.http.Vary = if(resp.http.Vary, resp.http.Vary ", Origin", "Origin");
  }

  # remove the Vary header for fonts to fix IE not loading fonts - https://jakearchibald.com/2014/browser-cache-vary-broken/#ie-fails-us
  if (resp.http.Vary && req.http.Original-URL ~ "\.woff" && req.http.Origin && (req.http.Origin ~ "^https?:\/\/(.+\.)?ft\.com(:\d+)?$" || req.http.Origin ~ "^https?:\/\/localhost(:\d+)?$")) {
    unset resp.http.Access-Control-Allow-Origin;
    set resp.http.Access-Control-Allow-Origin = "*";
    unset resp.http.Vary;
  }

  if (!req.http.Fastly-FF && req.http.Fastly-Debug) {
    set resp.http.Debug-Backend = req.http.Debug-Backend;
    set resp.http.Debug-Backend-Decision = req.http.Debug-Backend-Decision;
    set resp.http.Debug-Backend-Health = req.http.Debug-Backend-Health;
    set resp.http.Debug-Cache-State = fastly_info.state;
    set resp.http.Debug-Enable-Shielding = req.http.Debug-Enable-Shielding;
    set resp.http.Debug-Force-Region = req.http.Debug-Force-Region;
    set resp.http.Debug-Original-Url = req.http.Original-Url;
    set resp.http.Debug-Request-Header-Accept-Encoding = req.http.Accept-Encoding;
    set resp.http.Debug-Request-Header-User-Agent = req.http.User-Agent;
    set resp.http.Debug-Request-Host = req.http.Host;
    set resp.http.Debug-Request-Id = req.http.X-Request-Id;
    set resp.http.Debug-Request-Restarts = req.restarts;
    set resp.http.Debug-Url = req.url;
  } else {
    unset resp.http.Server;
    unset resp.http.Via;
    unset resp.http.X-Cache-Hits;
    unset resp.http.X-Cache-Policy;
    unset resp.http.X-Cache;
    unset resp.http.X-Powered-By;
    unset resp.http.X-Served-By;
    unset resp.http.X-Timer;
  }
}

sub vcl_error {
	if (obj.status == 901) {
		set obj.http.RUM-Debug = obj.response;
		set obj.status = 401;
		set obj.response = "Incorrect value for header FT-Origami-Key";
		set obj.http.Cache-Control = "max-age=0, must-revalidate, no-cache, no-store, private";
		return(deliver);
	}
}

# Route requests to the nearest backend.
include "multi-region-routing.vcl";

# Apply some caching logic.
include "caching.vcl";

# Add surrogate keys to the backend response.
include "surrogate-keys.vcl";

# Finally include the last bit of VCL, this _must_ be last!
include "fastly-boilerplate-end.vcl";
