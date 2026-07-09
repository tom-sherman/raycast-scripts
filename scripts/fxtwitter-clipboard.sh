#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fix Twitter link in clipboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐦
# @raycast.description Replace x.com/twitter.com with fxtwitter.com in the clipboard, but only when the clipboard holds nothing but a link.

clip=$(pbpaste)

# Trim surrounding whitespace/newlines.
trimmed=$(printf '%s' "${clip}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Bail out if the clipboard is anything other than a single bare URL.
# (A URL has no internal whitespace, so any space means there's other stuff.)
if [[ -z "${trimmed}" ]] || [[ "${trimmed}" =~ [[:space:]] ]]; then
  echo "Clipboard isn't just a link — left it alone."
  exit 0
fi

# Only touch x.com / twitter.com links.
if [[ ! "${trimmed}" =~ ^https?://(www\.)?(x|twitter)\.com/ ]]; then
  echo "Not an x.com/twitter.com link — left it alone."
  exit 0
fi

fixed=$(printf '%s' "${trimmed}" | sed -E 's#^(https?://)(www\.)?(x|twitter)\.com/#\1fxtwitter.com/#')

printf '%s' "${fixed}" | pbcopy

echo "${fixed}"
