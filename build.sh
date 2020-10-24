#!/bin/bash
set -ex

if [[ -z "$OUTPUT" ]]; then
    if [[ -n "$INPUT" ]]; then
        OUTPUT=$(basename $INPUT | awk '{print $1}' | sed 's/\.go$//g')
    elif [[ -n "$GITHUB_REPOSITORY" ]]; then
        OUTPUT=$(basename $GITHUB_REPOSITORY)
    else
        OUTPUT=$(basename $(pwd))
    fi
fi

if [[ -z "$PLATFORMS" ]]; then
    PLATFORMS=$(go tool dist list)
fi

OUTPUT_DIR=${OUTPUT_DIR:-"build"}

set +e

FAIL_PLATFORMS=""

for PLATFORM in $PLATFORMS; do
    GOOS=${PLATFORM%/*}
    GOARCH=${PLATFORM#*/}
    BINARY="${OUTPUT}-${GOOS}-${GOARCH}"
    if [[ "${GOOS}" == "windows" ]]; then BINARY="${BINARY}.exe"; fi
    TARGET="${OUTPUT_DIR}/${BINARY}"

    {
        LOG=$(GOOS=${GOOS} GOARCH=${GOARCH} go build -o ${TARGET} ${INPUT} 2>&1) && \
        XZ_OPT=-9e tar cJf ${TARGET}.tar.xz ${TARGET} --transform "s/${OUTPUT_DIR}\///g"
    } || FAIL_PLATFORMS="${FAIL_PLATFORMS} ${PLATFORM}"
done

if [[ -n "${FAIL_PLATFORMS}" ]]; then
    echo "Fail Platforms: ${FAIL_PLATFORMS}"
    exit 1
fi
