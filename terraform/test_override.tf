resource "fastly_service_v1" "app" {
  name = "Origami Build Service CDN Test (github.com/Financial-Times/origami-build-service)"

  // These domains are used by the staging Fastly service only.
  domain {
    name = "origami-build-service-cdn-test.in.ft.com"
  }
}
