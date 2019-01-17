#!/bin/sh

# Ensure Homebrew has been installed.
if ! [ -x "$(command -v brew)" ]; then
    echo "Error: Homebrew not installed" >&2
    exit 1
fi

brew update
brew upgrade
brew install ruby brew-gem
brew gem install bundler 2>/dev/null

echo "Insert the following lines into your .bash_profile (or .bashrc):"
echo
echo "export PATH=\"/usr/local/opt/ruby/bin:$PATH\""
echo "export PATH=\"/usr/local/lib/ruby/gems/2.6.0/bin:$PATH\""
