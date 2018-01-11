#
# Convert Edge-Control backend response headers into Surrogate-Control headers.
#
# https://docs.fastly.com/guides/tutorials/cache-control-tutorial
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
# https://docs.fastly.com/guides/vcl/support-for-the-edge-control-header
# https://docs.fastly.com/guides/vcl/isolating-header-values-without-regular-expressions
#

sub vcl_recv {
  # Sort query parameters for a better cache hit rate.
  set req.url = boltsort.sort(req.url);
}

sub vcl_fetch {
  # Keep things simple, Cache-Control takes precedence according to the specification.
  if (beresp.http.Cache-Control && beresp.http.Expires) {
    unset beresp.http.Expires;
  }

  # Only cache valid responses, see https://tools.ietf.org/html/rfc7231#section-6.1 for cacheable statuses.
  if (http_status_matches(beresp.status, "200,203,204,206,300,301,404,405,410,414,501")) {
    # Set a default Cache-Control of 1 minute.
    if (!beresp.http.Cache-Control && !beresp.http.Surrogate-Control && !beresp.http.Expires) {
      set beresp.http.Cache-Control = "max-age=60, stale-while-revalidate=60, stale-if-error=86400";
      set beresp.http.Surrogate-Control = "max-age=60, stale-while-revalidate=60, stale-if-error=86400";
      # Cache static content for 1 day.
      if (std.tolower(req.url.ext) ~ "(css|js|jpg|jpeg|gif|ico|png|bmp|pict|csv|doc|pdf|pls|ppt|tif|tiff|eps|ejs|swf|midi|mid|ttf|eot|woff|woff2|otf|svg|svgz|webp|docx|xlsx|xls|pptx|ps|class|jar)") {
        set beresp.http.Cache-Control = "max-age=86400, stale-while-revalidate=60, stale-if-error=86400";
        set beresp.http.Surrogate-Control = "max-age=86400, stale-while-revalidate=60, stale-if-error=86400";
      }
    }

  }
}
