{
  "time": "%{time.start.usec}V",
  "host": "%{if(req.http.Fastly-Orig-Host, req.http.Fastly-Orig-Host, req.http.Host)}V",
  "source": "%{req.service_id}V",
  "sourcetype": "_json",
  "event": {
    "request": {
      "id": "%{X-Request-Id}i",
      "path": "%{cstr_escape(req.url)}V",
      "method": "%{cstr_escape(req.request)}V",
      "user_agent": "%{User-Agent}i",
      "referrer_hostname": "%{regsub(regsub(json.escape(req.http.Referer), \"^.*\\/\\/\", \"\"), \"(\\/|\\?|:).*$\", \"\")}V",
      "accept_encoding": "%{Fastly-Orig-Accept-Encoding}i",
      "accept_language": "%{Accept-Language}i"
    },
    "response": {
      "status_code": "%>s",
      "content_encoding": "%{Content-Encoding}o",
      "content_type": "%{Content-Type}o",
      "location": "%{Location}o",
      "age": "%{Age}o",
      "time_elapsed": "%{time.elapsed.msec}V"
    },
    "size": {
      "request": {
        "header_bytes_read": "%{req.header_bytes_read}V",
        "body_bytes_read": "%{req.body_bytes_read}V"
      },
      "response": {
        "header_bytes_written": "%{resp.header_bytes_written}V",
        "body_bytes_written": "%{resp.body_bytes_written}V"
      },
      "backend": {
        "header_bytes_written": "%{bereq.header_bytes_written}V",
        "body_bytes_written": "%{bereq.body_bytes_written}V"
      }
    },
    "geolocation": {
      "latlong": "%{client.geo.latitude}V,%{client.geo.longitude}V",
      "city": "%{client.geo.city.utf8}V",
      "country": "%{client.geo.country_name.utf8}V",
      "country_code": "%{client.geo.country_code}V",
      "continent_code": "%{client.geo.continent_code}V",
      "region": "%{client.geo.region}V"
    },
    "fastly": {
      "cache_state": "%{regsub(fastly_info.state, \"^(HIT-(SYNTH)|(HITPASS|HIT|MISS|PASS|ERROR|PIPE)).*\", \"\\2\\3\") }V",
      "restarts": "%{req.restarts}V",
      "datacenter": "%{server.datacenter}V",
      "stale_exists": "%{if(stale.exists, \"true\", \"false\")}V"
    },
    "connection": {
      "client_ip": "%{Fastly-Client-IP}i",
      "tls": {
        "cipher": "%{cstr_escape(tls.client.cipher)}V",
        "protocol": "%{cstr_escape(tls.client.protocol)}V"
      },
      "h2": {
        "is_h2": "%{if(fastly_info.is_h2, \"true\", \"false\")}V",
        "is_push": "%{if(fastly_info.h2.is_push, \"true\", \"false\")}V"
      }
    }
  }
}
