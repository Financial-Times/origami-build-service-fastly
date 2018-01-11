resource "fastly_service_v1" "app" {
  name = "Origami Build Service CDN Test (github.com/Financial-Times/origami-build-service)"

  // These domains are used by the staging Fastly service only.
  domain {
    name = "origami-build-service-cdn-test.in.ft.com"
  }

  // Logging to S3, see https://docs.fastly.com/guides/streaming-logs/custom-log-formats for formats.
  s3logging {
    name           = "Request Logs"
    bucket_name    = "ft-cdn-logs"
    path           = "/origami-build-service-cdn-test.in.ft.com/test/"
    period         = "300"
    gzip_level     = 9
    format_version = 2
    format         = "%v [%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t] \"%r\" %>s %{req.bytes_read}V %{resp.bytes_written}V %{time.elapsed.msec}V %{tls.client.protocol}V %{fastly_info.state}V %{req.http.Fastly-FF}V"
    message_type   = "blank"
  }
}
