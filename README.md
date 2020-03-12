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
export FT_ORIGAMI_KEY=
```

# Fastly Shared Secrets

To authenticate requests between `www.ft.com` Fastly and our Fastly service , our service hecks for a shared secret added to requests.

The secret is stored in a Fastly Edge Dictionary. The Terraform configuration makes the dictionary, but we add the item to the dictionary via the Fastly UI manually.
