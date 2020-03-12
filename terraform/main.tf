provider "fastly" {
  version = "0.11.1"
}

variable "FT-Origami-Key" {
}

resource "fastly_service_v1" "app" {
  name = "Origami Build Service (github.com/Financial-Times/origami-build-service)"

  // Backend and healthcheck for the eu.
  backend {
    name                  = "origin_eu"
    address               = "origami-build-service-eu.herokuapp.com"
    port                  = 443
    healthcheck           = "origin_eu_healthcheck"
    ssl_cert_hostname     = "origami-build-service-eu.herokuapp.com"
    auto_loadbalance      = false
    shield                = "london_city-uk"
    connect_timeout       = 5000
    first_byte_timeout    = 120000
    between_bytes_timeout = 120000
    error_threshold       = 0
  }

  // Backend and healthcheck for the us.
  backend {
    name                  = "origin_us"
    address               = "origami-build-service-us.herokuapp.com"
    port                  = 443
    healthcheck           = "origin_us_healthcheck"
    ssl_cert_hostname     = "origami-build-service-us.herokuapp.com"
    auto_loadbalance      = false
    shield                = "iad-va-us"
    connect_timeout       = 5000
    first_byte_timeout    = 120000
    between_bytes_timeout = 120000
    error_threshold       = 0
  }

  // Healthcheck for eu.
  healthcheck {
    name      = "origin_eu_healthcheck"
    host      = "origami-build-service-eu.herokuapp.com"
    path      = "/__gtg"
    timeout   = 5000
    threshold = 2
    window    = 5
  }

  // Healthcheck for us.
  healthcheck {
    name      = "origin_us_healthcheck"
    host      = "origami-build-service-us.herokuapp.com"
    path      = "/__gtg"
    timeout   = 5000
    threshold = 2
    window    = 5
  }

  // Edge condition.
  condition {
    name      = "is_edge_server"
    statement = "!req.http.Fastly-FF"
    type      = "REQUEST"
    priority  = 10
  }

  // Enable gzip compression.
  gzip {
    name = "Compression Policy"

    // Fastly's default extensions to compress.
    extensions = ["css", "js", "html", "eot", "ico", "otf", "ttf", "json", "svg"]

    // Fastly's default content types to compress.
    content_types = ["text/html", "application/x-javascript", "text/css", "application/javascript", "text/javascript", "application/json", "application/vnd.ms-fontobject", "application/x-font-opentype", "application/x-font-truetype", "application/x-font-ttf", "application/xml", "font/eot", "font/opentype", "font/otf", "image/svg+xml", "image/vnd.microsoft.icon", "text/plain", "text/xml"]
  }

  // Custom VCL.
  vcl {
    name    = "main.vcl"
    content = file("${path.module}/../vcl/main.vcl")
    main    = true
  }
  vcl {
    name    = "caching.vcl"
    content = file("${path.module}/../vcl/caching.vcl")
  }
  vcl {
    name    = "fastly-boilerplate-begin.vcl"
    content = file("${path.module}/../vcl/fastly-boilerplate-begin.vcl")
  }
  vcl {
    name    = "fastly-boilerplate-end.vcl"
    content = file("${path.module}/../vcl/fastly-boilerplate-end.vcl")
  }
  vcl {
    name    = "multi-region-routing.vcl"
    content = file("${path.module}/../vcl/multi-region-routing.vcl")
  }
  vcl {
    name    = "surrogate-keys.vcl"
    content = file("${path.module}/../vcl/surrogate-keys.vcl")
  }

  dictionary {
    name = "secrets"
  }
}

resource "fastly_service_dictionary_items_v1" "items" {
  service_id    = "${fastly_service_v1.app.id}"
  dictionary_id = "${ { for dictionary in fastly_service_v1.app.dictionary : dictionary.name => dictionary.dictionary_id }["secrets"]}"

  items = {
    "FT-Origami-Key": var.FT-Origami-Key
  }
}