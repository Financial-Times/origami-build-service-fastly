"use strict";
const expect = require("chai").expect;
const request = require("./request-helper.js");

describe("cache headers", () => {
  it("removes cache headers specific to Fastly and Varnish", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/bundles/css?modules=o-grid@^4.0.0,o-fonts@^1.4.0",
        { debug: false }
      )
      .then(res => {
        expect(res).to.not.have.header("Edge-Control");
        expect(res).to.not.have.header("Expires");
        expect(res).to.not.have.header("Surrogate-Control");
        expect(res).to.not.have.header("X-External-Cache-Control");
      });
  });

  it("normalizes the Accept-Encoding header", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/bundles/css?modules=o-grid@^4.0.0,o-fonts@^1.4.0"
      )
      .then(res => {
        // The request sends a value of "gzip, deflate", Fastly only supports gzip or br.
        expect(res).to.have.header(
          "Debug-Request-Header-Accept-Encoding",
          "gzip"
        );
      });
  });
});
