#!/bin/sh
TOKEN_FILE="/runner/token"
REPO_FILE="/runner/repo"
if [ ! -f ${TOKEN_FILE} ]
then
  echo "No runner token found! Cannot cleanly shutdown."
  exit 1
fi

if [ ! -f ${REPO_FILE} ]
then
  echo "No repository found! Cannot cleanly shutdown."
  exit 1
fi

RUNNER_TOKEN=$(cat ${TOKEN_FILE})
RUNNER_REPOSITORY_URL=$(cat ${REPO_FILE})

echo "Exchanging the GitHub runner token for a remove token..."
_PROTO="$(echo "${RUNNER_REPOSITORY_URL}" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
_URL="$(echo "${RUNNER_REPOSITORY_URL/${_PROTO}/}")"
_PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
_ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
_REPO="$(echo "${_PATH}" | cut -d/ -f2)"

REMOVE_TOKEN="$(curl -XPOST -fsSL \
    -H "Authorization: token ${RUNNER_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${_ACCOUNT}/${_REPO}/actions/runners/remove-token" \
    | jq -r '.token')"

./config.sh remove --token ${REMOVE_TOKEN} --unattended
