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

### Caveats

We've only tested on AWS; only works with Ubuntu stemcell (uses `apt-get` to install PCRE pre-requisite).
