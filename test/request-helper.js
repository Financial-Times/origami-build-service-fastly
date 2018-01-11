"use strict";
const chai = require("chai");
const URL = require("url").URL;

chai.use(require("chai-http"));

const hostOverride = host =>
  process.env.CIRCLE_STAGE === "test_staging"
    ? host.replace(".in.ft.com", "-cdn-test.in.ft.com")
    : host;

// Handle the weird promise rejection required to test redirects.
module.exports = {
  get: (url, options = {}) => {
    const { host, pathname, search } = new URL(url);

    options = Object.assign(
      {
        debug: true, // True to not clean up headers in response delivery.
        userAgent: "chai-http",
        fakeClientIp: false
      },
      options
    );

    let request = chai
      .request("https://o2.shared.global.fastly.net")
      .get(`${pathname}${search}` || "")
      .set("FT-Origami-Key", process.env.FT_ORIGAMI_KEY)
      .set("Host", hostOverride(host))
      .set("Accept", "*/*")
      .set("Accept-Encoding", "gzip, deflate")
      .set("User-Agent", options.userAgent);

    if (options.debug) {
      request = request.set("Fastly-Debug", 1);
    }

    if (options.region) {
      request = request.set("Debug-Force-Region", options.region);
    }

    if (options.unhealthyEuOrigin) {
      request = request.set("Debug-Origin-EU-Force-Unhealthy", "yes");
    }

    if (options.unhealthyUsOrigin) {
      request = request.set("Debug-Origin-US-Force-Unhealthy", "yes");
    }

    if (options.unhealthyEuShield) {
      request = request.set("Debug-Shield-EU-Force-Unhealthy", "yes");
    }

    if (options.unhealthyUsShield) {
      request = request.set("Debug-Shield-US-Force-Unhealthy", "yes");
    }

    if (options.helpEverythingIsOnFire) {
      request = request.set("Debug-Shield-EU-Force-Unhealthy", "yes");
      request = request.set("Debug-Shield-US-Force-Unhealthy", "yes");
      request = request.set("Debug-Origin-EU-Force-Unhealthy", "yes");
      request = request.set("Debug-Origin-US-Force-Unhealthy", "yes");
    }

    if (options.fakeClientIp) {
      // Set a fake client IP that will trigger a 403 from the denied ACL.
      request = request.set("Fastly-Client-IP", "192.0.2.0");
    }

    return request
      .redirects(0)
      .then(res => res || Promise.reject(res))
      .catch(err => {
        if (!err.response) {
          throw err;
        }

        return err.response;
      });
  },

  post: url => {
    const { host, pathname, search } = new URL(url);

    return chai
      .request("https://o2.shared.global.fastly.net")
      .post(`${pathname}${search}` || "")
      .set("FT-Origami-Key", process.env.FT_ORIGAMI_KEY)
      .set("Host", hostOverride(host))
      .set("Fastly-Debug", 1)
      .then(res => res || Promise.reject(res))
      .catch(err => {
        if (!err.response) {
          throw err;
        }

        return err.response;
      });
  },

  purge: url => {
    const { host, pathname, search } = new URL(url);

    return chai
      .request("https://o2.shared.global.fastly.net")
      .purge(`${pathname}${search}` || "")
      .set("FT-Origami-Key", process.env.FT_ORIGAMI_KEY)
      .set("Host", hostOverride(host))
      .then(res => res || Promise.reject(res))
      .catch(err => {
        if (!err.response) {
          throw err;
        }

        return err.response;
      });
  }
};
