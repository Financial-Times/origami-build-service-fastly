"use strict";
const expect = require("chai").expect;
const request = require("./request-helper.js");

describe("surrogate keys", () => {
  const req = request.get("https://origami-build-service.in.ft.com/");

  it("responses have a Surrogate-Key header", () => {
    return req.then(res => {
      expect(res).to.have.header("Surrogate-Key");
    });
  });

  it("has an `all` key", () => {
    return req.then(res => {
      expect(res.headers["surrogate-key"].split(" ")).to.contain("all");
    });
  });

  it("has the backend region as a key", () => {
    return req.then(res => {
      expect(res).to.have.header("Surrogate-Key", /(eu|us)/);
    });
  });

  it("has the host as a key", () => {
    return request.get(`https://origami-build-service.in.ft.com/`).then(res => {
      try {
        expect(res.headers["surrogate-key"].split(" ")).to.contain(
          "origami-build-service-eu.herokuapp.com"
        );
      } catch (e) {
        expect(res.headers["surrogate-key"].split(" ")).to.contain(
          "origami-build-service-us.herokuapp.com"
        );
      }
    });
  });

  it("has `js` as a key for js requests", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/bundles/js?modules=o-grid@^4.0.0,o-fonts@^1.4.0"
      )
      .then(res => {
        expect(res.headers["surrogate-key"].split(" ")).to.contain("js");
      });
  });

  it("has `css` as a key for css requests", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/bundles/css?modules=o-grid@^4.0.0,o-fonts@^1.4.0"
      )
      .then(res => {
        expect(res.headers["surrogate-key"].split(" ")).to.contain("css");
      });
  });

  it("has `demos` as a key for demos requests", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/demos/o-tabs@4.0.4/buttontabs"
      )
      .then(res => {
        expect(res.headers["surrogate-key"].split(" ")).to.contain("demos");
      });
  });

  it("has `files` as a key for files requests", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/files/o-tabs@4.0.4/origami.json"
      )
      .then(res => {
        expect(res.headers["surrogate-key"].split(" ")).to.contain("files");
      });
  });

  it("has `modules` as a key for modules requests", () => {
    return request
      .get("https://origami-build-service.in.ft.com/v2/modules/o-tabs@4.0.4")
      .then(res => {
        expect(res.headers["surrogate-key"].split(" ")).to.contain("modules");
      });
  });
});
