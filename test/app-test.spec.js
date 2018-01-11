"use strict";

const expect = require("chai").expect;
const request = require("./request-helper.js");
const URL = require("url").URL;

describe("origami-build-service.in.ft.com", () => {
  it("serves the origami build service", () => {
    return request
      .get("https://origami-build-service.in.ft.com/__about")
      .then(res => {
        expect(res).to.be.ok;
        expect(res).to.be.json;
        expect(res.body.systemCode).to.equal("build-service");
      });
  });

  const urls = [
    "https://origami-build-service.in.ft.com",
    "https://origami-build-service.in.ft.com/v2/",
    "https://origami-build-service.in.ft.com/v2/bundles/css?modules=o-grid@^4.0.0,o-fonts@^1.4.0",
    "https://origami-build-service.in.ft.com/v2/bundles/js?modules=o-grid@^4.0.0,o-fonts@^1.4.0",
    "https://origami-build-service.in.ft.com/v2/demos/o-tabs@4.0.4/buttontabs",
    "https://origami-build-service.in.ft.com/v2/files/o-tabs@4.0.4/origami.json",
    "https://origami-build-service.in.ft.com/v2/modules/o-tabs@4.0.4"
  ];

  urls.forEach(url => {
    const { pathname, search } = new URL(url);

    it(`serves ${pathname}${search} ok`, () => {
      return request.get(url).then(res => {
        expect(res).to.be.ok;
      });
    });
  });

  const req = request.get("https://origami-build-service.in.ft.com/v2");

  it("give each request a unique request id", () => {
    return request
      .get("https://origami-build-service.in.ft.com/v2")
      .then(res => {
        expect(res).to.have.header("Debug-Request-Id");
      });
  });

  it("serves the index page", () => {
    return req.then(res => {
      expect(res).to.be.ok;
      expect(res).to.be.html;
    });
  });

  it("caches the index page", () => {
    return req.then(res => {
      expect(res).to.have.header("Cache-Control", /max-age/);
    });
  });

  it("compresses the response", () => {
    return req.then(res => {
      expect(res).to.have.header("Content-Encoding", "gzip");
    });
  });

  it("passes on the User-Agent header", () => {
    return req.then(res => {
      expect(res).to.have.header(
        "Debug-Request-Header-User-Agent",
        "chai-http"
      );
    });
  });

  it("removes debug headers", () => {
    return request
      .get("https://origami-build-service.in.ft.com/v2", { debug: false })
      .then(res => {
        expect(res).to.not.have.header("Edge-Control");
        expect(res).to.not.have.header("Expires");
        expect(res).to.not.have.header("Server");
        expect(res).to.not.have.header("Surrogate-Control");
        expect(res).to.not.have.header("Via");
        expect(res).to.not.have.header("X-Cache-Hits");
        expect(res).to.not.have.header("X-Cache-Policy");
        expect(res).to.not.have.header("X-Cache");
        expect(res).to.not.have.header("X-Powered-By");
        expect(res).to.not.have.header("X-Served-By");
        expect(res).to.not.have.header("X-Timer");
      });
  });

  it("sorts query parameters", () => {
    return request
      .get("https://origami-build-service.in.ft.com/v2/?b=2&a=1&v=4&s=true")
      .then(res => {
        expect(res).to.have.header(
          "Debug-Original-Url",
          "/v2/?b=2&a=1&v=4&s=true"
        );
        expect(res).to.have.header("Debug-Url", "/v2/?a=1&b=2&s=true&v=4");
      });
  });
});
