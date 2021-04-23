# Go Build Actions

Github Actions to cross build go binary

## Usage

```yaml
- uses: t-actions/go-build@master
  with:
    # Platforms to build
    # Default is all platforms by $(go tool dist list)
    platforms: ''

    # Input parameters, if not build from root folder
    input: ''

    # Output binary name
    # Default is repository name
    output: ''

    # Output folder name
    # Default is 'build'
    output_dir: ''
```

## Output Format

Will build a binary and compress it to `tar.xz` in the format below. (windows binary will have `.exe` suffix)

```bash
# For non arm
${OUTPUT_DIR}/${OUTPUT}-${GOOS}-${GOARCH}
${OUTPUT_DIR}/${OUTPUT}-${GOOS}-${GOARCH}.tar.xz
# For arm
${OUTPUT_DIR}/${OUTPUT}-${GOOS}-${GOARCH}v${GOARM}
${OUTPUT_DIR}/${OUTPUT}-${GOOS}-${GOARCH}v${GOARM}.tar.xz
```
