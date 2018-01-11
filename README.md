# Origami Build Service Fastly Configuration [![CircleCI](https://circleci.com/gh/Financial-Times/origami-build-service.svg?style=svg&circle-token=3b13194e890d3a532f92ffbf26e1369506e80223)](https://circleci.com/gh/Financial-Times/workflows/origami-build-service/tree/master)

Fastly configuration for the Origami Build Service.

Using Terraform and CircleCI for continuous deployment, with regression tests running after the deploy.

This service accepts traffic from the `www.ft.com` Fastly service, it is not intended to be hit directly.

The environment variables required in the CircleCI pipeline are as follows.

```shell
# So that we can limit deploys to one at a time.
export CIRCLE_TOKEN=

# To authenticate with the Fastly API.
export FASTLY_API_KEY=

# For logging requests to S3.
export FASTLY_S3_ACCESS_KEY=
export FASTLY_S3_SECRET_KEY=

# For running the test suite
export ORIGAMI_KEY=
```

# Simulate Global Routing Failures

Within `multi-region-routing.vcl` we define several request headers that can be used to simulate unhealthy backends.

* `Fastly-Force-Region` can be `EU` or `US`
* Set `Fastly-Origin-EU-Force-Unhealthy` to simulate a failing EU origin
* Set `Fastly-Origin-US-Force-Unhealthy` to simulate a failing US origin
* Set `Fastly-Shield-EU-Force-Unhealthy` to simulate a failing EU shield
* Set `Fastly-Shield-US-Force-Unhealthy` to simulate a failing US shield

# Fastly Shared Secrets

To authenticate requests between `www.ft.com` Fastly and our Fastly service , our service hecks for a shared secret added to requests.

The secret is stored in a VCL Snippet, which can be seen in the Fastly UI. It is kept out of this repository because it is a secret.

# FT Tooling Team

The tooling team manage several chunks of VCL to enforce WAF, and two shared ACLs.

Both `ft_manage_blacklist` and `FT_Internal_IP_Whitelist` are ACLs that we shouldn't have to manage, but should be aware of, and enforce.

For WAF, there's nothing in the UI to view yet. You will see the addition of some logging and condition artifacts in both the UI and Terraform, until there is 100% for WAF in Terraform.

With `req.http.bypass_waf`, this **must** be set explicitly to prevent a means of skipping WAF.
