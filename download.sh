# ./jq '.version' < meta/defaults/Workflows.json

version=`./jq '.version' < meta/defaults/Workflows.json | sed 's|"||g'`
name=`./jq '.name' < meta/defaults/Workflows.json| sed 's|"||g'`
language=`./jq '.language' < meta/defaults/Workflows.json| sed 's|"||g'`
url=`./jq '.url' < meta/defaults/Workflows.json| sed 's|"||g'`
zip=`./jq '.zip' < meta/defaults/Workflows.json| sed 's|"||g'`

data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"

# echo $name
# echo $version
# echo $language
# echo $url
# echo $zip
filname=`echo "$url" | awk -F"/" '{print $NF }'`
echo $filename
if [ ! -d "$cache" ]; then
  mkdir "$cache"
fi

if [ $language != "utility" ]; then
  if [ ! -d "$data/libraries" ]; then
    mkdir "$data/libraries"
  fi
  if [ ! -d "$data/libraries/$language" ]; then
    mkdir "$data/libraries/$langauge"
  fi
  if [ ! -d "$data/libraries/$language/$version" ]; then
    mkdir "$data/libraries/$language/$version"
  fi
  if [ "$zip" == "true" ]; then
    filname=`$url | awk -F"/" '{print $NF }'`

  else
    a=1
  fi
else
  if [ ! -d "$data/utilities" ]; then
    mkdir "$data/utilities"
  fi
fi
