#!/bin/bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd $SCRIPTS_DIR

function cleanup() {
  rm -rf $SCRIPTS_DIR/output \
    $SCRIPTS_DIR/resume.json \
    $SCRIPTS_DIR/resume.yaml \
    $SCRIPTS_DIR/resume.html \
    $SCRIPTS_DIR/resume.pdf
}

RESUME_YAML_SOURCE_FILE="../${RESUME_SOURCE_YAML_FILE:-resume.yaml}" 
if [ ! -f $RESUME_YAML_SOURCE_FILE ]; then
  echo "The supplied Resume YAML Source File was not found at: ${RESUME_SOURCE_YAML_FILE}"
  cleanup
  exit 1
fi

mkdir -p ./output/
cp $RESUME_YAML_SOURCE_FILE ./resume.yaml
cp $RESUME_YAML_SOURCE_FILE ./output/resume.yaml

cat resume.yaml | yq -o=json > ./resume.json
npm install
RESUME_CLI_COMMAND=./node_modules/resume-cli/build/main.js

$RESUME_CLI_COMMAND validate
if [ $? != 0 ]; then
  echo "Something went wrong validatiing the resulting YAML -> JSON format and the JSON is corrupted or the YAML is broken"
  cleanup
  exit 1
fi
cp resume.json ./output/

$RESUME_CLI_COMMAND export --theme kendall resume.html
mv resume.html ./output/

$RESUME_CLI_COMMAND export --theme kendall resume.pdf
mv resume.pdf ./output/

rm -f resume.json
rm -f resume.yaml

popd