#! /bin/bash
og_name=$1

if [ $2 ]
then
  new_name=$2
else
  new_name="$og_name.new"
fi

echo "editing $og_name to $new_name"

tail -n +2 $og_name > $new_name