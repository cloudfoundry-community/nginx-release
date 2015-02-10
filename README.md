# BOSH-deployed ISC DHCP Server

This BOSH release can be used to deploy a DHCP server.

### Procedure

```
git clone git@github.com:pivotal-cf-experimental/nginx-server-release.git
cd nginx-server-release
bosh create release
bosh upload release 
bosh deployment your-manifest-dhcpd.yml
bosh deploy
```

### Sample Deployment

A sample manifest is available in the `examples` subdirectory.

### Caveats

We've only tested on AWS; only works with Ubuntu stemcell (uses `apt-get` to install PCRE pre-requisite).
