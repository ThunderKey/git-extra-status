#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;93m'
NC='\033[0m'

cwd=$PWD
repos=$@

for arg in "$@"; do
	if [[ "$arg" == "--submodules" ]] || [[ "$arg" == "-s" ]]; then
		shift
		SUBMODULES="true"
	elif [[ "$arg" == "--verbose" ]] || [[ "$arg" == "-v" ]]; then
		shift
		VERBOSE="true"
	elif [[ "$arg" == "-sv" ]] || [[ "$arg" == "-vs" ]]; then
		shift
		VERBOSE="true"
		SUBMODULES="true"
	fi
done

if [ $# -eq 0 ]; then
	repos="${cwd}"
fi

print_git_status() {
	local repo="$1"
	local repo_name="$2"
	local padding="$3"
	local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
	if [[ "$BRANCH_NAME" == "HEAD" ]]; then
		local GIT_STATUS="${YELLOW}?${NC} Unknown branch"
	else
		local GIT_STATUS=$(git-status)
	fi
	printf "$padding[$repo_name] - ${BRANCH_NAME}\n"
	if [[ -n $(git status --porcelain) ]]; then
		printf "$padding   ${GIT_STATUS} ${RED}x${NC} Uncommitted Changes\n"
	else
		printf "$padding   ${GIT_STATUS}\n"
	fi
  if [[ "$VERBOSE" == "true" ]]; then
    git status --short
  fi
	if [[ "$SUBMODULES" == "true" ]]; then
		repo_path="$PWD"
		for submodule in $(git submodule status | awk '{print $2}'); do
			pushd $submodule > /dev/null
			print_git_status "$submodule" "$submodule" "$padding   "
			popd > /dev/null
		done
	fi
}

printf "   \n"
for repo in $repos; do
	repo=$(abspath "$repo")
	if [[ -e "${repo}/.git" ]]; then
		pushd $repo > /dev/null
		print_git_status $repo "$(basename "$repo")" " "
		popd > /dev/null
	fi
done
