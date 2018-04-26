## Developer Notes

Bumping version (e.g. to 1.13.12):

```
export OLD_VERSION=1.12.2
export VERSION=1.13.12
cd ~/workspace/nginx-release
git pull -r
find packages/nginx -type f -print0 |
  xargs -0 perl -pi -e \
  "s/nginx-${OLD_VERSION}/nginx-${VERSION}/g"
 # FIXME: update README.md's download URL
bosh add-blob \
  ~/Downloads/nginx-${VERSION}.tar.gz \
  nginx/nginx-${VERSION}.tar.gz
vim config/blobs.yml
  # delete `nginx/nginx-${OLD_VERSION}.tar.gz` stanza
bosh create-release --force
bosh -e vbox upload-release
bosh -e vbox -n -d nginx \
  deploy manifests/nginx-lite.yml --recreate
 # `bosh -e vbox vms`; browse to nginx VM
bosh upload-blobs
bosh create-release \
  --final \
  --tarball ~/Downloads/nginx-release-${VERSION}.tgz \
  --version ${VERSION} --force
git add -N releases/
git add -p
git ci -v
git tag $VERSION
git push
git push --tags
```
