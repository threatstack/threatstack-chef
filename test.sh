#!/usr/bin/env bash
result=0
echo "Foodcritic . . ."
bundle exec foodcritic -f any .
result=$(($result + $?))
echo "Rubocop . . ."
bundle exec rubocop
result=$(($result + $?))

if [ $result -eq 0 ]; then
  echo "SUCCESS"
else
  echo "FAILURE"
fi

exit $result
