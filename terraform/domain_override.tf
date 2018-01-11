resource "fastly_service_v1" "app" {
  domain {
    name = "origami-build-service.in.ft.com"
  }
}
