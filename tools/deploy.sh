#!/usr/bin/env bash
#
# Build, test and then deploy the site content to 'origin/<pages_branch>'
#
# Requirement: html-proofer, jekyll
#
# Usage: See help information

set -eu

PAGES_BRANCH="gh-pages"

SITE_DIR="_site"

_opt_dry_run=false

_config="_config.yml"

_no_pages_branch=false

_backup_dir="$(mktemp -d)"

_baseurl=""

help() {
  echo "Build, test and then deploy the site content to 'origin/<pages_branch>'"
  echo
  echo "Usage:"
  echo
  echo "   bash ./tools/deploy.sh [options]"
  echo
  echo "Options:"
  echo '     -c, --config   "<config_a[,config_b[...]]>"    Specify config file(s)'
  echo "     --dry-run                Build site and test, but not deploy"
  echo "     -h, --help               Print this information."
}

genOgImage() {
  node fixfrontmatter.js
  node ogGen.js
}



init() {
  if [[ -z ${GITHUB_ACTION+x} && $_opt_dry_run == 'false' ]]; then
    echo "ERROR: It is not allowed to deploy outside of the GitHub Action envrionment."
    echo "Type option '-h' to see the help information."
    exit -1
  fi

  _baseurl="$(grep '^baseurl:' _config.yml | sed "s/.*: *//;s/['\"]//g;s/#.*//")"
}

build() {
  # clean up
  if [[ -d $SITE_DIR ]]; then
    rm -rf "$SITE_DIR"
  fi

  # build
  JEKYLL_ENV=production bundle exec jekyll b -d "$SITE_DIR$_baseurl" --config "$_config"
}

test() {
  bundle exec htmlproofer \
    --disable-external \
    --check-html \
    --allow_hash_href \
    "$SITE_DIR"
}

resume_site_dir() {
  if [[ -n $_baseurl ]]; then
    # Move the site file to the regular directory '_site'
    mv "$SITE_DIR$_baseurl" "${SITE_DIR}-rename"
    rm -rf "$SITE_DIR"
    mv "${SITE_DIR}-rename" "$SITE_DIR"
  fi
}

setup_gh() {
  if [[ -z $(git branch -av | grep "$PAGES_BRANCH") ]]; then
    _no_pages_branch=true
    git checkout -b "$PAGES_BRANCH"
  else
    git checkout -f "$PAGES_BRANCH"
  fi
}

backup() {
  mv "$SITE_DIR"/* "$_backup_dir"
  mv .git "$_backup_dir"

  # When adding custom domain from Github website,
  # the CANME only exist on `gh-pages` branch
  if [[ -f CNAME ]]; then
    mv CNAME "$_backup_dir"
  fi
}

flush() {
  rm -rf ./*
  rm -rf .[^.] .??*

  shopt -s dotglob nullglob
  echo "$_backup_dir"
  cp "$_backup_dir"/* .
  [[ -f ".nojekyll" ]] || echo "" >".nojekyll"
}

deploy() {
  git config --global user.name "GitHub Actions"
  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

  git update-ref -d HEAD
  git add -A
  git commit -m "[Automation] Site update No.${GITHUB_RUN_NUMBER}"

  if $_no_pages_branch; then
    git push -u origin "$PAGES_BRANCH"
  else
    git push -f
  fi
}

deploy_to_another_repo() {
  echo "Deploying to the r74tech/blog.r74.tech repository"

  # Specify the second repository and branch
  ANOTHER_REPO_URL="https://github.com/r74tech/blog.r74.tech.git"
  ANOTHER_PAGES_BRANCH="gh-pages"

  # Clone the target repository to a temporary directory
  TEMP_REPO_DIR="$(mktemp -d)"
  git clone $ANOTHER_REPO_URL $TEMP_REPO_DIR
  cd $TEMP_REPO_DIR

  # Checkout the target branch or create it if it doesn't exist
  if [[ -z $(git branch -av | grep "$ANOTHER_PAGES_BRANCH") ]]; then
    git checkout -b "$ANOTHER_PAGES_BRANCH"
  else
    git checkout "$ANOTHER_PAGES_BRANCH"
  fi

  # Copy the built site contents to the temporary repository directory
  rm -rf *
  echo "$_backup_dir"
  cp -r $_backup_dir/* .

  # Commit and push the changes to the second repository
  git add -A
  git commit -m "[Automation] Site update No.${GITHUB_RUN_NUMBER} for r74tech/blog.r74.tech"
  git push -u origin "$ANOTHER_PAGES_BRANCH" || git push -f

  # Clean up
  cd ..
  rm -rf $TEMP_REPO_DIR

  echo "Deployment to r74tech/blog.r74.tech completed"
}



main() {
  genOgImage
  init
  build
  # test
  resume_site_dir

  if $_opt_dry_run; then
    exit 0
  fi

  setup_gh
  backup
  flush
  deploy
  deploy_to_another_repo
}

while (($#)); do
  opt="$1"
  case $opt in
  -c | --config)
    _config="$2"
    shift
    shift
    ;;
  --dry-run)
    # build & test, but not deploy
    _opt_dry_run=true
    shift
    ;;
  -h | --help)
    help
    exit 0
    ;;
  *)
    # unknown option
    help
    exit 1
    ;;
  esac
done

main
