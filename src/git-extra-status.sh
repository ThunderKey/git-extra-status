#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;93m'
NC='\033[0m'

cwd=$PWD
repos=$@

if [ $# -eq 0 ]; then
	repos="${cwd}"
fi

printf "   \n"
for repo in $repos; do
	repo=$(abspath "$repo")
	if [[ -d "${repo}/.git" ]]; then
		cd $repo
		BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
		if [[ "$BRANCH_NAME" == "HEAD" ]]; then
			GIT_STATUS="${YELLOW}?${NC} Unknown branch"
		else
			GIT_STATUS=$(git-status)
		fi
		printf " [$(basename "$repo")] - ${BRANCH_NAME}\n"
		if [[ -n $(git status --porcelain) ]]; then
			printf "    ${GIT_STATUS} ${RED}x${NC} Uncommitted Changes\n"
		else
			printf "    ${GIT_STATUS}\n"
		fi
		printf "\n\n"
		cd $cwd
	fi
done