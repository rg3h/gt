#!/usr/bin/zsh
# @fileoverview gtUtils.sh utility functions
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

# sanitize a string to be a valid repoName
# Example Usage: unsafeName="  Unsafe ------ Name 2/2## w/ special chars.txt  "
# local cleanedName=$(sanitizeRepoName "${unsafeName}")
sanitizeRepoName() {
  local s="${1?need a string}"
  # s="${s:l}"       # convert to lowercase
  s="${s//[^[:alnum:]_.-]/-}" # replace bad chars with "-" allow alphanum _ . -

  # convert multiple hyphens to single "-"  Loop since //-+/- not supported
  s="${s//--/-}"
  local charCount=${#s}
  repeat ${charCount} s="${s//--/-}"

  s="${s/#-}"      # remove leading/trailing hyphens
  s="${s/%-}"
  print -r -- "${s}"
}


# repo name cant have spaces, must be lowercase (for consistency across OS)
# usage: if $(isValidRepoName "oh boy"); then print "good"; else print "bad"; fi
isValidRepoName() {
  local cleaned=$(sanitizeRepoName ${1})
  local validStatus=false
  if [[ ${cleaned} == ${1} ]]; then validStatus=true; fi
  print -r -- ${validStatus}
}
