"use strict";
const expect = require("chai").expect;
const request = require("./request-helper.js");

describe("purge", () => {
  it("rejects unauthorized purge requests", () => {
    return request
      .purge("https://origami-build-service.in.ft.com/v2")
      .then(res => expect(res).to.have.status(401));
  });
});
