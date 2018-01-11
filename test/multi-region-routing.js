"use strict";
const expect = require("chai").expect;
const request = require("./request-helper.js");

const url = "https://origami-build-service.in.ft.com/v2";

describe("multi-region routing", () => {
  describe("EU request", () => {
    it("uses the EU shield", () => {
      return request.get(url, { region: "EU" }).then(res => {
        expect(res).to.have.header("Fastly-Debug-Path", /cache-(.+)-LCY/);
      });
    });

    it("uses the EU origin when the EU shield is unhealthy", () => {
      return request
        .get(url, { region: "EU", unhealthyEuShield: true })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_eu/);
        });
    });

    it("uses the US shield when the EU shield and origin are unhealthy", () => {
      return request
        .get(url, {
          region: "EU",
          unhealthyEuShield: true,
          unhealthyEuOrigin: true
        })
        .then(res => {
          expect(res).to.have.header("Fastly-Debug-Path", /cache-(.+)-IAD/);
        });
    });

    it("uses the US origin when the US shield, EU shield and origin are unhealthy", () => {
      return request
        .get(url, {
          region: "EU",
          unhealthyEuShield: true,
          unhealthyUsShield: true,
          unhealthyEuOrigin: true
        })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_us/);
        });
    });

    it("uses the EU origin when everything is on fire", () => {
      return request
        .get(url, { region: "EU", helpEverythingIsOnFire: true })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_eu/);
        });
    });
  });

  describe("US request", () => {
    it("uses the US shield", () => {
      return request.get(url, { region: "US" }).then(res => {
        expect(res).to.have.header("Fastly-Debug-Path", /cache-(.+)-IAD/);
      });
    });

    it("uses the US origin when the US shield is unhealthy", () => {
      return request
        .get(url, { region: "US", unhealthyUsShield: true })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_us/);
        });
    });

    it("uses the EU shield when the US shield and origin are unhealthy", () => {
      return request
        .get(url, {
          region: "US",
          unhealthyUsShield: true,
          unhealthyUsOrigin: true
        })
        .then(res => {
          expect(res).to.have.header("Fastly-Debug-Path", /cache-(.+)-LCY/);
        });
    });

    it("uses the EU origin when the EU shield, US shield and origin are unhealthy", () => {
      return request
        .get(url, {
          region: "US",
          unhealthyUsShield: true,
          unhealthyUsOrigin: true,
          unhealthyEuShield: true
        })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_eu/);
        });
    });

    it("uses the US origin when everything is on fire", () => {
      return request
        .get(url, { region: "US", helpEverythingIsOnFire: true })
        .then(res => {
          expect(res).to.have.header("Debug-Backend", /origin_us/);
        });
    });
  });
});
