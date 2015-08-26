# BOSH-deployed Nginx Server

This BOSH release can be used to deploy a Nginx server.

### Procedure

```
git clone git@github.com:pivotal-cf-experimental/nginx-bosh-release.git
cd nginx-bosh-release
bosh create release
bosh upload release 
bosh deployment your-manifest-nginx.yml
bosh deploy
```

### Sample Deployment

A sample manifest is available in the `examples` subdirectory.

### Jobs

There are two jobs:

* nginx: runs the nginx server
* fetcher: periodically fetches [computationally] expensive pages for the nginx
  server to server as static pages. Discussion of this job is beyond the scope
  of this document and it can be safely ignored (i.e. you don't need to instantiate
  the job in the BOSH manifest).

### Caveats

We've only tested on AWS; only works with Ubuntu stemcell (uses `apt-get` to install PCRE pre-requisite).
