# BOSH-deployed nginx Server

This [BOSH](https://bosh.io/) release deploys an nginx webserver.

### 0. Quick Start

#### 0.0 Quick Start: Pre-requisites

You must have a BOSH Director and have uploaded stemcells to it. Our examples assume the [BOSH CLI v2](https://github.com/cloudfoundry/bosh-cli).

Here's a quick-start to install [BOSH Lite](https://github.com/cloudfoundry/bosh-lite):

```bash
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/cloudfoundry/bosh-lite.git
cd bosh-lite
vagrant up # you have installed Vagrant, haven't you?
bosh2 -e 192.168.50.4 alias-env lite --ca-cert=ca/certs/ca.crt
bosh2 -e lite login # admin/admin
```

Upload Ubuntu stemcell

```bash
bosh2 -e lite us https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3421.11-warden-boshlite-ubuntu-trusty-go_agent.tgz
```

Add the route

```bash
bin/add-route
```

Clone the nginx repository; upload the Cloud Config:

```bash
cd ~/workspace
git clone https://github.com/cloudfoundry-community/nginx-release.git
cd nginx-release
bosh2 -e lite ucc manifests/cloud-config-lite.yml
```

#### 0.1 Quick Start: Upload release to BOSH Director

```bash
bosh2 -e lite ur https://github.com/cloudfoundry-community/nginx-release/releases/download/v1.12.0/nginx-1.12.0.tgz
```

#### 0.2 Quick Start: deploy

(This assumes you're in the `~/workspace/nginx` directory cloned in a previous step):

```bash
bosh2 -e lite -d nginx deploy manifests/nginx-lite.yml
```

#### 0.3 Quick Start: test

Browse to <http://10.244.0.10/>; you should see the following:

![nginx_release_welcome](https://user-images.githubusercontent.com/1020675/27837760-14599acc-609b-11e7-8e1a-eb4d305be2b7.png)

### 1. Post-deployment HTML content



We find it effective to set the `pre_start` property to populate
the webserver content. See [here](https://bosh.io/docs/pre-start.html)
for an example (sslip.io).

Alternatively, you may manually add the HTML content *after* successful deployment.

We recommend installing HTML content on the persistent disk, e.g.
`/var/vcap/store/nginx/document_root/` so that subsequent redeploys
do not require re-installation of HTML content, i.e. the
`nginx.conf` should have the following directive:

```
server {
  root /var/vcap/store/nginx/www/document_root;
```

## Notes

#### 1. nginx Job Properties

* `nginx_conf`: *Required*. This contains the contents of nginx's configuration
  file, nginx.conf. Here is the beginning from a sample configuration:
  ```yaml
    nginx_conf: |
      worker_processes  1;
      error_log /var/vcap/sys/log/nginx/error.log   info;
  ```

* `ssl_key`: *Optional*, defaults to ''. This contains the contents of the
  SSL key in PEM-encoded format. This is required if deploying an HTTPS webserver.
  The key is deployed to the path `/var/vcap/jobs/nginx/etc/ssl.key.pem` and
  requires the following line in the `nginx_conf`'s *server* definition:

  ```
  ssl_certificate_key /var/vcap/jobs/nginx/etc/ssl.key.pem;
  ```

  Here is the beginning from a sample configuration:

  ```yaml
  ssl_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIJKQIBAAKCAgEAyv4in6scMw3OkBlr++1OooLuZQKftmwGIO8puOj6lSH4H1LI
  ```

* `ssl_chained_cert`: *Optional*, defaults to ''. This contains the contents of the
  SSL certificate in PEM-encoded format. This file will most likely contain several
  chained certificates.
  The certificate for the server should appear at the
  top, followed by the intermediate certificate.
  This property is required if deploying an HTTPS webserver.
  The certificate is deployed to the path `/var/vcap/jobs/nginx/etc/ssl_chained.crt.pem` and
  requires the following line in the `nginx_conf` *server* definition:

  ```
  ssl_certificate     /var/vcap/jobs/nginx/etc/ssl_chained.crt.pem;
  ```

  Here is the beginning from a sample configuration:

  ```yaml
  ssl_chained_cert: |
    -----BEGIN CERTIFICATE-----
    MIIGSjCCBTKgAwIBAgIRAOxg+vyhygau6bc2SAooL6owDQYJKoZIhvcNAQELBQAw
  ```

* `pre_start`: *Optional*, contains a pre-start script to execute,
useful for populating web content.
