"use strict";
const expect = require("chai").expect;
const request = require("./request-helper.js");

describe("web application firewall", () => {
  /*
   TODO: Unskip these when the ACLs are added to our Fastly service by the FT Tooling team.
  */
  it.skip("rejects bad requests", () => {
    return request
      .get(
        "https://origami-build-service.in.ft.com/v2/<script>alert(1)<script>?v=2"
      )
      .then(res => expect(res).to.have.status(403));
  });

  it.skip("rejects clients in the denied ACL", () => {
    return request
      .get("https://origami-build-service.in.ft.com/v2", { fakeClientIp: true })
      .then(res => expect(res).to.have.status(403));
  });
});
