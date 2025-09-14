#!/bin/bash
envfile=$1

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ ! "$line" =~ ^# && -n "$line" ]]; then
    eval export "$line"
  fi
done < "$envfile"
