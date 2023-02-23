#!/usr/bin/env bash

# Unset previously configured hooks if such
if git config --get core.hooksPath > /dev/null; then
  echo "Unsetting previously added core.hooksPath"
  git config --unset core.hooksPath
fi

# Install pre-commit and other requirements
if which brew > /dev/null; then
  echo "Installing pre-commit package manager via brew..."
  brew install pre-commit
else
  echo "Installing pre-commit package manager via pip3..."
  pip3 install pre-commit
fi

echo "Installing pre-commit hooks..."
pre-commit install -t pre-commit -t pre-push


# Install checkov
if ! which checkov > /dev/null; then
  if which brew > /dev/null; then
    echo "Installing checkov with brew..."
    brew install checkov
  else
    echo "Installing checkov..."
    pip3 install checkov
  fi
fi

echo "Git hooks are set up"
