# BOSH-deployed nginx Server

This BOSH release deploys nginx server.

### 1. Upload release to BOSH Director

```
bosh upload release https://github.com/cloudfoundry-community/nginx-release/releases/download/v4/nginx-4.tgz
```

### 2. Create BOSH manifest to deploy nginx server

* Use the `nginx.yml` manifest from the `examples/` subdirectory as a template
* Search for all occurrences of `FIXME` and modify as appropriate
* You may need to adjust your [cloud config](https://bosh.io/docs/cloud-config.html);
  `examples/cloud-config-aws.yml` is an AWS-specific *Cloud Config* that
  corresponds with `nginx.yml`. Merge that with your *Cloud Config*.
* If you're using [bosh-init](https://bosh.io/docs/using-bosh-init.html)
  instead of a BOSH Director, use the `nginx-aws-bosh-init.yml` as an
  example *bosh-init* manifest.

### 3. Deploy

Update your *Cloud Config* and deploy the release:

```bash
bosh update cloud-config merged-cloud-config.yml
bosh deployment nginx.yml
bosh deploy
```

### 4. Post-deployment HTML content

You must manually add the HTML content *after* successful deployment.

We recommend installing HTML content on the persistent disk, e.g.
`/var/vcap/store/nginx/document_root/` so that subsequent redeploys
do not require re-installation of HTML content, i.e. the
`nginx.conf` should have the following directive:

```
server {
  root /var/vcap/store/nginx/www/document_root;
```

In the following example, we use `git` to clone our HTML
content for our website, sslip.io.

We ssh into our deployed VM.

```bash
# ssh in and become root
ssh -i $AWS_KEY_PAIR vcap@$ELASTIC_IP
sudo su - # password is 'c1oudc0w'
mkdir -p /var/vcap/store/nginx/www/ # create if needed
git clone https://github.com/cunnie/sslip.io.git /var/vcap/store/nginx/document_root/
```

Browse to your VM's elastic IP to ensure that the page loads as expected.

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

### Caveats

* We've only tested on AWS
