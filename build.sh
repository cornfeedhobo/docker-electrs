#!/usr/bin/env bash

set -eu

if [ -n "${DEBUG:-}" ]; then
	set -x
fi

version="$(< VERSION)"

version_sha="$(curl -LSs "https://api.github.com/repos/romanz/electrs/git/ref/tags/${version}" | jq -r '.object.sha')"

build_date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

build_tag="${BUILD_TAG:-cornfeedhobo/electrs:$version}"

build_script=(
	docker build "${*}"
	--build-arg="BUILD_DATE=${build_date}"
	--build-arg="ELECTRS_VERSION=${version}"
	--build-arg="ELECTRS_HASH=${version_sha}"
	--tag="${build_tag}"
	.
)

sed \
	-e "s/[[:space:]]\+-/ \\\\\n    -/g" \
	-e "s/[[:space:]]\+\./ \\\\\n    \./" \
	<<<"${build_script[*]}"

echo 'Are you ready to proceed?'

select confirm in 'Yes' 'No'; do
	case $confirm in
		Yes)
			# shellcheck disable=2048
			exec ${build_script[*]}
			;;
		*)
			exit
			;;
	esac
done
