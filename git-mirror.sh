#!/usr/bin/env bash
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

  Mirrors a git repo including:
    all branches, notes and tags
    and pruning.

  Usage:
    ${_ME} source_git_url target_git_url
HEREDOC
}

_main() {
  if [[ "$#" -ne 2 || "${1:-}" =~ ^-h|--help$ ]]; then
    _usage
    exit 1
  fi

  local source target repo_dir
  source="${1:?}"
  target="${2:?}"
  repo_dir="$(basename "${source}" .git).git"

  ## Clones repo if it does not exist.
  if [ ! -d "${repo_dir}" ]; then
    git clone --bare "${source}"
    cd "${repo_dir}" || exit
    git config --add remote.origin.fetch '+refs/heads/*:refs/heads/*'
    git config --add remote.origin.fetch '+refs/notes/*:refs/notes/*'
    git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'
    git config remote.origin.mirror true
    git remote set-url --push origin "${target}"
    cd -
  fi

  ## Do initial push or update the mirror
  cd "${repo_dir}" || exit
  git fetch --all --prune
  git push --mirror --prune
  cd -
}

_main "$@"
