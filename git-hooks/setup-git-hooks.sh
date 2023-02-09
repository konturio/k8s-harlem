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

# Install terraform-docs
if ! which terraform-docs > /dev/null; then
  if which brew > /dev/null; then
    echo "Installing terraform-docs with brew..."
    brew install terraform-docs
  else
    echo "Installing terraform-docs..."
    curl -sSLo /tmp/terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
    tar -xzf /tmp/terraform-docs.tar.gz -C /tmp/
    chmod +x /tmp/terraform-docs
    mv /tmp/terraform-docs /usr/local/bin/terraform-docs
  fi
fi

# Install tflint
if ! which tflint > /dev/null; then
  if which brew > /dev/null; then
    echo "Installing tflint with brew..."
    brew install tflint
  else
    echo "Installing tflint..."
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  fi
fi

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