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

  # Gather the health of the shields and origins.
  declare local var.origin_eu_is_healthy BOOL;
  set req.backend = F_origin_eu;
  set var.origin_eu_is_healthy = (req.backend.healthy && !req.http.Debug-Origin-EU-Force-Unhealthy);

  declare local var.origin_us_is_healthy BOOL;
  set req.backend = F_origin_us;
  set var.origin_us_is_healthy = (req.backend.healthy && !req.http.Debug-Origin-US-Force-Unhealthy);

  declare local var.shield_eu_is_healthy BOOL;
  set req.backend = ssl_shield_london_city_uk;
  set var.shield_eu_is_healthy = (req.backend.healthy && !req.http.Debug-Shield-EU-Force-Unhealthy);

  declare local var.shield_us_is_healthy BOOL;
  set req.backend = ssl_shield_iad_va_us;
  set var.shield_us_is_healthy = (req.backend.healthy && !req.http.Debug-Shield-US-Force-Unhealthy);

  # Route EU requests to the nearest healthy shield or origin.
  if (var.region == "EU") {
    if (server.identity !~ "-LCY$" && req.http.Fastly-FF !~ "-LCY" && var.shield_eu_is_healthy) {
      set req.backend = ssl_shield_london_city_uk;
      set req.http.FT-Region = server.region;
    } elseif (var.origin_eu_is_healthy) {
      set req.backend = F_origin_eu;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } elseif (var.shield_us_is_healthy) {
      set req.backend = ssl_shield_iad_va_us;
      set req.http.FT-Region = server.region;
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

  # Route US requests to the nearest healthy shield or origin.
  if (var.region == "US") {
    if (server.identity !~ "-IAD$" && req.http.Fastly-FF !~ "-IAD" && var.shield_us_is_healthy) {
      set req.backend = ssl_shield_iad_va_us;
      set req.http.FT-Region = server.region;
    } elseif (var.origin_us_is_healthy) {
      set req.backend = F_origin_us;
      set req.http.FT-Region = server.region;
      set req.http.Host = table.lookup(origin_hosts, var.region);
    } elseif (var.shield_eu_is_healthy) {
      set req.backend = ssl_shield_london_city_uk;
      set req.http.FT-Region = server.region;
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
