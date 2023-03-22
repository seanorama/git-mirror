#/usr/bin/env bash
#
# Mirrors a git repo.

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o nounset
set -o pipefail
IFS=$'\n\t'
_ME="$(basename "${0}")"

_usage() {
  cat <<HEREDOC
  
  Mirrors a git repo.
  
  Usage:
    ${_ME} source_git_url target_git_url
}

_main() {
  if [ "$#" -ne 2 ]; then
    _usage
    exit 1
  fi

  local source="${1:?}"
  local target="${2:?}"
  local repo_name="$(basename "${source}")"
  if [ ! -d "${repo_name}" ]; then
    git clone --bare "${source}"
    cd "${repo_name}" || exit
    git config --add remote.origin.fetch '+refs/heads/*:refs/heads/*'
    git config --add remote.origin.fetch '+refs/notes/*:refs/notes/*'
    git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'
    git config remote.origin.mirror true
    git remote set-url --push origin "${target}"
    cd -
  fi
  cd "${repo_name}" || exit
  git fetch --all --prune
  git push --mirror --prune
  cd -
}

_main "$@"
