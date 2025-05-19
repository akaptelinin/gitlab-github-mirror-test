#!/bin/bash

echo "RUNNING post-receive" >> /tmp/hook_log.txt

GEN_SCRIPT="/generate_conflict.sh"  # защищённое место
GITHUB_REPO="https://$(cat /run/secrets/github_token)@github.com/akaptelinin/gitlab-github-mirror-test.git"
BRANCH="development"

while read oldrev newrev refname; do
  if [[ "$refname" == "refs/heads/$BRANCH" ]]; then
    WORKDIR=$(mktemp -d)
    git clone --branch "$BRANCH" --single-branch "$GITHUB_REPO" "$WORKDIR"
    cd "$WORKDIR" || exit 1

    FILE="dev_conflict.txt"
    if [ ! -f "$FILE" ]; then
      bash "$GEN_SCRIPT" "$FILE"

      git config user.name "hook-bot"
      git config user.email "hook-bot@example.com"
      git add "$FILE"
      NOW="$(date '+%d %b %Y %H:%M' | tr '[:upper:]' '[:lower:]')"
      git commit -m "post-receive: автогенерация конфликта новой версии dev со старой. $NOW"

      # Проверка, не было ли новых пушей
      git fetch origin "$BRANCH"
      LOCAL_HASH=$(git rev-parse HEAD)
      REMOTE_HASH=$(git rev-parse origin/"$BRANCH")
      if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo "Branch $BRANCH updated while processing, exit."
        cd /
        rm -rf "$WORKDIR"
        exit 1
      fi

      git push origin HEAD:"$BRANCH"
    fi

    cd /
    rm -rf "$WORKDIR"
  fi
done

exit 0
