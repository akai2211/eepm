#!/bin/bash
set -e

if [ "$CI_PIPELINE_SOURCE" = "schedule" ]; then
  echo "Pipeline triggered by schedule — skipping generate_ci"
  exit 0
fi
# Подгружаем origin/devel, чтобы было с чем сравнивать
git fetch origin devel >/dev/null 2>&1 || true

# Получаем список изменённых приложений
CHANGED_APPS=$(git diff --name-only HEAD~1 \
  | awk -F/ '/^(play|pack|repack)\.d\// {
      gsub(/\.sh$/, "", $2);
      print $2
    }' \
  | sort -u)

echo "Изменены: $CHANGED_APPS"

# Если изменения есть — генерируем .gitlab-ci.yml
if [ -n "$CHANGED_APPS" ]; then
  echo "Changes found, regenerating..."
  bash gen-ci.sh $CHANGED_APPS > .gitlab-ci.yml
  git config user.name "CI Bot"
  git config user.email "ci@etersoft.ru"
  git checkout -B ci-generated
  git add .gitlab-ci.yml
  git commit -m "update gitlab-ci.yml from epmp list" --allow-empty
  git remote set-url origin https://vanomj:$CI_PUSH_TOKEN@gitlab.eterfund.ru/vanomj/eepm.git
  git push -f origin ci-generated
else
  echo "No relevant changes in play.d/, pack.d/, or repack.d/. Skipping."
fi
