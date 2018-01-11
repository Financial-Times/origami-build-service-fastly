#
# Add surrogate keys.
#

sub vcl_fetch {
  if (req.http.Fastly-FF) {

    #
    # Generic surrogate keys which are useful for most services
    #

    # Add the "all" key, soft-purge all the things.
    set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " all", "all");

    # Add the host as a key, e.g. "www.ft.com".
    set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " " req.http.Host, req.http.Host);

    # Add the "eu" key.
    if (req.backend == F_origin_eu) {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " eu", "eu");
    }

    # Add "us" key.
    if (req.backend == F_origin_us) {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " us", "us");
    }

    #
    # Custom surrogate keys which are useful for only this specific service
    #

    # Add the "js" key.
    if (req.url ~ "^/v2/bundles/js") {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " js", "js");
    }

    # Add the "css" key.
    if (req.url ~ "^/v2/bundles/css") {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " css", "css");
    }

    # Add the "files" key.
    if (req.url ~ "^/v2/files") {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " files", "files");
    }

    # Add the "modules" key.
    if (req.url ~ "^/v2/modules") {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " modules", "modules");
    }

    # Add the "demos" key.
    if (req.url ~ "^/v2/demos") {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " demos", "demos");
    }

    # Add keys for Vary header values.
    if (beresp.http.Vary:Accept-Encoding) {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " vary-accept-encoding", "vary-accept-encoding");
    }

    if (beresp.http.Vary:Origin) {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " vary-origin", "vary-origin");
    }

    if (beresp.http.Vary:Access-Control-Request-Headers) {
      set beresp.http.Surrogate-Key = if(beresp.http.Surrogate-Key, beresp.http.Surrogate-Key " vary-access-control-request-headers", "vary-access-control-request-headers");
    }
  }
}
