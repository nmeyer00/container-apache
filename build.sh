#!/bin/bash
set -e

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

#
# Examples:
# ./build.sh '' test
# ./build.sh '--build-arg APK_UPGRADE=true' test
# 

runOptions="${1-}"
name="${2-}"

IMAGE=$(tools/latestBaseImage.sh)
returnCode=$?

if [ $returnCode -gt 0 ]; then
  echo "ERROR - Image not found"
  exit 1
fi

imageVersion=`echo "$IMAGE" | awk -F':' '{print $2}'`
echo "Image: $IMAGE"
echo "Version: $imageVersion"

docker rmi  nmeyer99/apache-httpd:${imageVersion} 2>/dev/null || true
docker rmi  nmeyer99/apache-httpd:latest 2>/dev/null || true
if [ "$runOptions" == "--build-arg APK_UPGRADE=true" ]; then
  echo "APK_UPGRADE=TRUE"
  imageVersion="latest"
else
  echo "APK_UPGRADE=FALSE" 
fi

docker build ${runOptions} --build-arg BASEIMAGE="${IMAGE}" --build-arg IMAGE_VERSION="$(git describe --tags --always --dirty 2>/dev/null || echo dev)" -t nmeyer99/apache-httpd:${imageVersion} .

if [[ -n "$name" ]]; then
  echo "Running container: $name"
  docker run --rm --name "$name" -p 8080:8080 nmeyer99/apache-httpd:${imageVersion}
fi
exit 0