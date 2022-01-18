#!/bin/bash
set -ex

if [[ -z "$OUTPUT" ]]; then
    if [[ -n "$GITHUB_REPOSITORY" ]]; then
        OUTPUT=$(basename $GITHUB_REPOSITORY)
    else
        OUTPUT="main"
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

    if [[ "${GOARCH}" == "arm" ]]; then
        GOARMS=(7 6 5)
    else
        GOARMS=("")
    fi

    for GOARM in "${GOARMS[@]}"; do
        BINARY="${OUTPUT}-${GOOS}-${GOARCH}${GOARM:+v${GOARM}}"
        if [[ "${GOOS}" == "windows" ]]; then BINARY="${BINARY}.exe"; fi
        TARGET="${OUTPUT_DIR}/${BINARY}"

        {
            LOG=$(GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go build -o ${TARGET} ${INPUT} 2>&1) && \
            XZ_OPT=-9e tar cJf ${TARGET}.tar.xz ${TARGET} --transform "s/${OUTPUT_DIR}\///g" && \
            sha256sum ${TARGET} > ${TARGET}.sha256 && \
            sha256sum ${TARGET}.tar.xz > ${TARGET}.tar.xz.sha256
        } || FAIL_PLATFORMS="${FAIL_PLATFORMS} ${PLATFORM}${GOARM:+v${GOARM}}"
    done
done

if [[ -n "${FAIL_PLATFORMS}" ]]; then
    echo "Fail Platforms: ${FAIL_PLATFORMS}"
    exit 1
fi
