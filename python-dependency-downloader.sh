#!/bin/sh

### Define some variables
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"
wget="$data/utilities/wget"

# Check to see if a directory exists, if not, make it.
dir() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  fi
}

dir "$cache"
dir "$cache/python-tmp"

dir "$data"
dir "$data/assets"
dir "$data/assets/python"

function getPackage {
echo "Get package for P:$1 V:$2"
  # $1 Package Name
  # $2 Package Version (optional)
  local package="$1"
  local version="$2"

"$data/utilities/terminal-notifier.app/Contents/MacOS/terminal-notifier" -title "Alfred Bundler"  -message "Attempting to install $package $version." -remove ALL  > /dev/null

  if [ -d "$cache/python-tmp/$package" ]; then
    rm -fR "$cache/python-tmp/$package"
  fi
  dir "$cache/python-tmp/$package"

  cd "$cache/python-tmp/$package"
  if [ -z "$version" ]; then
    `"$wget" --quiet -O "$package.json" https://pypi.python.org/pypi/$package/json`
  else
    `"$wget" --quiet -O "$package.json" https://pypi.python.org/pypi/$package/$version/json`
  fi
  cd - > /dev/null
  local url=`python parse-json.py "$cache/python-tmp/$package/$package.json"`
  if [ -z "$url" ]; then
    echo "BAD URL with https://pypi.python.org/pypi/$package/$version/json"
    exit
  fi
  `"$wget" --quiet $url -P "$cache/python-tmp/$package"`
  cd "$cache/python-tmp/$package"
  IFS='.' read -a kind <<< "${url}"

  ext=${kind[${#kind[@]}-1]}
  if [ "$ext" == 'gz' ]; then
    tar zxf *.gz
  elif [ "$ext" == 'zip' ]; then
    unzip -q *.zip
  fi

  dir "$data/assets/python/$package"

  # We weren't passed a version, so we'll just get it from the downloaded folder name
  if [ -z "$version" ]; then
    local dir=`find "$cache/python-tmp/$package/"* -maxdepth 0 -type d  2>/dev/null`
    IFS='-' read -a parts <<< "${dir}"
    local version=${parts[${#parts[@]}-1]}
  fi
  # Check to see if a setup.py file is there. If so, copy/rename the sub-directory
  # (because of how those packages are, well, pacakged)
#   Actually... I need to read through the setup.py file to find the exact directory
#   or the py modules... see notes at the end of this.
  if [ -f "$cache/python-tmp/$package/$package-$version/setup.py" ]; then
    cp -R "$cache/python-tmp/$package/$package-$version/$package" "$data/assets/python/$package/"
    mv "$data/assets/python/$package/$package/*" "$data/assets/python/$package/$version"
  else
    cp -R "$cache/python-tmp/$package/$package-$version" "$data/assets/python/$package/"
    mv "$data/assets/python/$package/$package-$version/*" "$data/assets/python/$package/$version"
  fi
  cd - > /dev/null

"$data/utilities/terminal-notifier.app/Contents/MacOS/terminal-notifier" -title "Alfred Bundler"  -message "Installed $package $version successfully. Looking for dependencies..." -remove ALL > /dev/null

  findGetRequirements $package $version

}

function findGetRequirements {
  echo "Find requirements for P:$1 V:$2"
  # $1 Package Name
  # $2 Package Version (optional)
  local package="$1"
  local version="$2"

  echo "Looking for $package $version requirements"

  if [ -z $version ]; then
    local dir=`find "$cache/python-tmp/$package/"* -maxdepth 0 -type d  2>/dev/null`
  else
    local dir="$cache/python-tmp/$package/$package-$version"
  fi

  local t=`find "$dir/"*egg-info -maxdepth 0 -type d  2>/dev/null `
  echo $t
  if [ -f "$t/requires.txt" ]; then
    echo "We're reading the requires.txt file"
    while read line
    do
      local match=`php query-map.php "$line"`
      if [ $match == "no package" ]; then
        local match=`echo $line | sed 's| ||g' | sed 's| ||g' | sed 's| ||g' | sed 's|  | |g'`
        read -a args <<< "$match"
        getPackage ${args[0]} ${args[1]}
      elif [ $match == "no match" ]; then
        local match=`echo $line | sed 's| ||g' | sed 's| ||g' | sed 's| ||g' | sed 's|  | |g'`
        read -a args <<< "$match"
        getPackage ${args[0]} ${args[1]}
      else
        local match=`echo $match | sed 's| ||g' | sed 's| ||g' | sed 's| ||g' | sed 's|  | |g'`
        echo $match
        read -a args <<< "$line"
        getPackage ${args[0]} ${args[1]}
      fi
    done < "$t/requires.txt"
  elif [ -f "$dir/requirements.txt" ]; then
    echo "We're reading the requirements.txt file"
    while read line
    do
      if [[ "$line" =~ (\=\=) ]]; then
        IFS='==' read -a req <<< "$line"
        for element in "${req[@]}"
        do
          if [ ! -z "$element" ]; then
            if [[ "$element" =~ ([a-z]{1,}) ]]; then
              local p="$element"
            elif [[ "$element" =~ ([0-9\.]{1,}) ]]; then
              local v="$element"
            fi

            # if [ `checkPackage $p $v` == 'no' ]; then
              #
            # fi
          fi

        done
        getPackage $p $v
        # echo "Looking for $p $v"
        dir "$data/assets"
        dir "$data/assets/python"
      fi
    done < "$dir/requirements.txt"
  elif [ -f "$dir/requires.txt" ]; then
    echo "Requires.txt exists"
  elif [ -f "$dir/setup.py" ]; then
    echo "Setup.py exists"
  fi
}

function checkPackage {
  # $1 Package Name
  # $2 Package Version (optional)
  local package="$1"
  local version="$2"

  # Right now, this will simply exit if the package exists but the dependencies
  # do not exist... so we'll have to fix that later.

  if [ ! -z "$version" ]; then
    if [ -d "$data/assets/python/$package/$version" ]; then
      echo $version # we found that package with that version
      return 0
    fi
  fi
  if [ -d "$data/assets/python/$package" ]; then
    OLDIFS=$IFS; IFS=$'\n' # Just change the separator for a minute.
    local v=(`find "$data/assets/python/$package/"* -maxdepth 0 -type d  2>/dev/null`)
    if [[ ${#v[@]} -eq 0 ]]; then
      echo "no" # the directory is there but with no versions
    elif [[ ${#v[@]} -eq 1 ]]; then
      echo $v
    else
      local f="${v[${#v[@]}-1]}" # This should be the newest directory
      IFS='/' read -a vs <<< "$f"
      version="${vs[${#vs[@]}-1]}"
      echo $version # Echo the version to be used
      return 0
    fi
    IFS=$OLDIFS # Reset the seperator
  else
    echo "no" # the package directory isn't there
    return 0
  fi

}

# if [ `checkPackage $1 $2` == 'no' ]; then
  getPackage $1 $2
# fi


constructLinks() {
#   place holder
a=1
}


# So, since I'm doing this incredibly recursively, I'll need to create some tmp
# files to make sure that I move everything into the right place afterward.

#  The below lines are to help me through the setup.py file
# packages = ['py',
#             'py._code...',...]
# package_dir = {'': 'feedparser'},
# py_modules = ['pytest_cov']  (((( ./pytest_cov.py))))
