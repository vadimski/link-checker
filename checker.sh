#!/bin/bash

STATUS_CODE=0
### Script parameters
while getopts ":f:hv" opt; do
  case $opt in
  f)
    LOCATION=$OPTARG
    ;;
  v)
    VERBOSE=1
    ;;
  h)
    cat help
    echo
    exit
    ;;
  \?)
    echo "Invalid option '$OPTARG'. Use '-h' to display the help information."
    exit 1
    ;;
  :)
    echo "Option '$OPTARG' requires an argument. Use '-h' to display the help information."
    exit 1
    ;;
  esac
done

if [[ -z "$LOCATION" ]]; then
  echo "Please provide file location (-f /path/to/file)"
  exit 1
fi

if [[ ! -f $LOCATION ]]; then
  echo "{$LOCATION} file does not exit"
  exit 1
fi

echo "File location provided: ${LOCATION}"

function checkStatusCode() {
  local RESPONSE=$1
  local CHECK_STATUS_CODE=$2

  STATUS_CODE_FOUND=$(echo "$RESPONSE" | grep "HTTP/2 ${CHECK_STATUS_CODE}")

  if [[ -z $STATUS_CODE_FOUND ]]; then
    STATUS_CODE=$(echo "$RESPONSE" | grep "HTTP/2" | cut -d ' ' -f2)
    return 1
  fi
}

echo "Running ..."

while IFS= read -r URL; do
  if [[ -n $VERBOSE ]]; then
    echo "Processing: ${URL}"
  fi

  RESPONSE=$(curl -s -i "${URL}")
  EXIT_CODE=$?
  if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo "URL: ${URL}"
    echo "CURL exited with exit code: ${EXIT_CODE}"
  else
    checkStatusCode "$RESPONSE" 200 || (echo "URL: ${URL}" && echo "HTTP status code: ${STATUS_CODE}")
  fi
  echo "   "
done <"$LOCATION"
echo "Done."
exit 0
