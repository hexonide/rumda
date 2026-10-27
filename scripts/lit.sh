#!/usr/bin/env zsh

LIT_DIR=${LIT_DIR:-$HOME/.local/state/lit}

usage() {
  cat <<'EOF'
Usage: lit [options] [paths...]

Search tracked files with git grep for long number literals.

Options:
  -d N      minimum digits for decimal literals (default 5)
  -b N      minimum digits for hex and binary literals (default 5)
  -p REGEX  search for this pattern instead of number literals
            (also turns off the default exclusion filter)
  -e REGEX  exclude lines matching this regex
  -x PATH   exclude this file or folder from the search (repeatable)
  -o FILE   save results to FILE (default: $LIT_DIR/latest.txt)
  -k        also keep a timestamped copy in $LIT_DIR
  -q        open the results in nvim quickfix instead of printing
  -f        print the most common line starts instead of the hits
  -r        reopen the last results in nvim quickfix, without searching
  -h        show this help

Results are saved under $LIT_DIR (default: ~/.local/state/lit).
EOF
}

main() {
  local -a o_d o_b o_p o_e o_x o_o o_k o_q o_f o_r o_h
  zparseopts -D -E -- d:=o_d b:=o_b p:=o_p e:=o_e x+:=o_x o:=o_o k=o_k q=o_q f=o_f r=o_r h=o_h

  if (( $#o_h )); then
    usage
    return 0
  fi

  if [[ ${1:-} == -* && ${1:-} != -- ]]; then
    print -u2 "lit: unknown option $1"
    usage >&2
    return 2
  fi

  mkdir -p $LIT_DIR
  local out=${o_o[2]:-$LIT_DIR/latest.txt}

  if (( $#o_r )); then
    nvim -q $out -c copen
    return
  fi

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -u2 "lit: not inside a git repository"
    return 1
  fi

  local dd=${o_d[2]:-5}
  local bb=${o_b[2]:-5}
  local pat exc

  if (( $#o_p )); then
    pat=$o_p[2]
  else
    pat="(^|[^[:alnum:]_.])([0-9]{$dd,}|0x[0-9a-fA-F]{$bb,}|0b[01]{$bb,})"
  fi

  if (( $#o_e )); then
    exc=$o_e[2]
  elif (( $#o_p )); then
    exc='^$'
  else
    exc='(issue|since|version) = "|issue #|https?://'
  fi

  local -a skip
  local a
  for a in ${o_x:#-x}; do
    skip+=(":(exclude)$a")
  done

  git grep -nE "$pat" -- "$@" $skip | grep -vE "$exc" > $out

  if (( $#o_k )); then
    cp $out $LIT_DIR/$(date +%Y%m%d-%H%M%S).txt
  fi

  print -u2 "$(wc -l < $out) hits saved to $out"

  if (( $#o_f )); then
    sed -E 's/^[^:]*:[0-9]*:\s*//' $out | cut -c1-20 | sort | uniq -c | sort -rn | head -15
  elif (( $#o_q )); then
    nvim -q $out -c copen
  else
    cat $out
  fi
}

main "$@"
