#!/bin/bash

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulp_file' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

set -euv

# make sure this script runs at the repo root
cd "$(dirname "$(realpath -e "$0")")"/../../..


mkdir ~/.gem || true
touch ~/.gem/credentials
echo "---
:rubygems_api_key: $RUBYGEMS_API_KEY" > ~/.gem/credentials
sudo chmod 600 ~/.gem/credentials

export VERSION=$(ls pulp_file_client* | sed -rn 's/pulp_file_client-(.*)\.gem/\1/p')

if [[ -z "$VERSION" ]]; then
  echo "No client package found."
  exit
fi

export response=$(curl --write-out %{http_code} --silent --output /dev/null https://rubygems.org/gems/pulp_file_client/versions/$VERSION)

if [ "$response" == "200" ];
then
  echo "pulp_file client $VERSION has already been released. Skipping."
  exit
fi

GEM_FILE="$(ls pulp_file_client-*)"
gem push ${GEM_FILE}
