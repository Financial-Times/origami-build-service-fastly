#
# Multi-region routing to serve requests from the nearest backend.
#

table origin_hosts {
  "US": "origami-build-service-us.herokuapp.com",
  "EU": "origami-build-service-eu.herokuapp.com",
}

sub vcl_recv {
  # Calculate the ideal region to route the request to.
  declare local var.region STRING;

  if (client.geo.continent_code ~ "(NA|SA|OC|AS)") {
    set var.region = "US";
  } else {
    set var.region = "EU";
  }

  if (req.http.Debug-Force-Region == "US") {
    set var.region = "US";
  }

  if (req.http.Debug-Force-Region == "EU") {
    set var.region = "EU";
  }

  # Gather the health of the origins.
  declare local var.origin_eu_is_healthy BOOL;
  set req.backend = F_origin_eu;
  set var.origin_eu_is_healthy = req.backend.healthy;

  declare local var.origin_us_is_healthy BOOL;
  set req.backend = F_origin_us;
  set var.origin_us_is_healthy = req.backend.healthy;

  # Route EU requests to the nearest healthy origin.
  if (var.region == "EU") {
    if (var.origin_eu_is_healthy) {
      set req.backend = F_origin_eu;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } elseif (var.origin_us_is_healthy) {
      set req.backend = F_origin_us;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } else {
      # Everything is on fire...
      set req.backend = F_origin_eu;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    }
  }

  # Route US requests to the nearest healthy origin.
  if (var.region == "US") {
    if (var.origin_us_is_healthy) {
      set req.backend = F_origin_us;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } elseif (var.origin_eu_is_healthy) {
      set req.backend = F_origin_eu;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } else {
      # Everything is on fire...
      set req.backend = F_origin_us;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    }
  }

  # Persist the decision so we can debug the result.
  set req.http.Debug-Backend = req.backend;
}
