# BOSH-deployed nginx Server

This BOSH release can be used to deploy an nginx server.

### Procedure for creating the BOSH manifest

Copy a manifest from the examples subdirectory. If you're not using SSL, copy *nginx-aws.yml*. If you're using SSL, copy *nginx-ssl-aws.yml*.

```bash
cp examples/nginx-aws.yml ~
```
Edit your BOSH manifest. Search for occurrences of "CHANGEME" and substitute your values as appropriate.

```bash
vim ~/nginx-aws.yml
```

While editing, remember to populate the *nginx* job's configuration (i.e. `nginx.conf`). For example,

```yaml
jobs:
- name: nginx
  properties:
    nginx_conf: |
      worker_processes  1;
      error_log /var/vcap/sys/log/nginx/error.log   info;
      #pid        logs/nginx.pid; # PIDFILE is configured via monit's ctl
      events {
        worker_connections  1024;
      }
      http {
        include /var/vcap/packages/nginx-1.6.2/conf/mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
        server_names_hash_bucket_size 64;
        server {
          listen 80;
          access_log /var/vcap/sys/log/nginx/sslip.io-access.log;
          error_log /var/vcap/sys/log/nginx/sslip.io-error.log;
        }
      }
```

If you have an existing manifest and you want to add nginx to it, make sure to include the nginx final release tarball:

```yaml
releases:
  - name: nginx
    url: https://s3.amazonaws.com//nginx-release/nginx-2.tgz
    sha1: 667cc1a0f9117bdb4b217ee2b76dc20e61371c02
```

### Deploy

Deploy the release to AWS:

```bash
bosh-init deploy ~/nginx-aws.yml
```

### HTML content

You must manually add the HTML content *after* successful deployment (irritating, we know)

First, set your environment variables. You'll need the elastic IP of the deployed VM
and the key pair to ssh in. Both these items should be in the BOSH manifest:

```bash
export ELASTIC_IP=52.0.76.229 # substitute your VM's elastic IP
export AWS_KEY_PAIR=~/.ssh/aws_nono.pem # substitute the path to your key pair
```

Next, copy the *document_root* directory onto the VM. The document root
should have the file index.html (e.g. *document_root/index.html*)

```bash
# copy the files to the nginx VM's /tmp/ directory
scp -r -i $AWS_KEY_PAIR document_root vcap@$ELASTIC_IP:/tmp/
```

We assume that in the BOSH manifest that the nginx.conf specifies
*/var/vcap/jobs/nginx/document_root* as the root. We move our
uploaded file into place:

```bash
# ssh in and become root
ssh -i $AWS_KEY_PAIR vcap@$ELASTIC_IP
sudo su - # password is 'c1oudc0w'
mv /tmp/document_root /var/vcap/jobs/nginx/
```

Point your browser to your VM's elastic IP and make sure that the page is the one
you expect.

### BOSH Jobs

There are two jobs:

1. nginx: runs the nginx server
1. fetcher: periodically fetches [computationally] expensive pages for the nginx
  server to server as static pages. Discussion of this job is beyond the scope
  of this document and it can be safely ignored (i.e. you don't need to instantiate
  the job in the BOSH manifest).

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
  chained certificates (unless by some miracle your certificate was issued by
  a root certificate). The certificate for the server should appear at the
  top of the file, followed by intermediate certificate that issued the server's
  certificate next.
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

### Caveats

* We've only tested on AWS
* works with Ubuntu and CentOS stemcell (uses `apt-get` to install PCRE pre-requisite on Ubuntu)
