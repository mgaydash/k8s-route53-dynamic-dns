#!/bin/bash

usage() {
  echo "ROUT53_ADMIN_AWS_HOSTED_ZONE_ID, ROUT53_ADMIN_AWS_ACCESS_KEY_ID and ROUT53_ADMIN_AWS_SECRET_ACCESS_KEY should be set"
}

RELEASE_NAME="route53-dynamic-dns"

if [[ "${ROUT53_ADMIN_AWS_ACCESS_KEY_ID}" == "" ]] \
|| [[ "${ROUT53_ADMIN_AWS_HOSTED_ZONE_ID}" == "" ]] \
|| [[ "${ROUT53_ADMIN_AWS_SECRET_ACCESS_KEY}" == "" ]]; then
  usage
  exit 1
fi

helm upgrade \
  --install \
  --set "aws_access_key_id=${ROUT53_ADMIN_AWS_ACCESS_KEY_ID}" \
  --set "aws_secret_access_key=${ROUT53_ADMIN_AWS_SECRET_ACCESS_KEY}" \
  --set "hosted_zone_id=${ROUT53_ADMIN_AWS_HOSTED_ZONE_ID}" \
  --values ./values.yaml \
  ${RELEASE_NAME} \
  .
