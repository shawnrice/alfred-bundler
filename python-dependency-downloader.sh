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

getPackage() {
  # $1 Package Name
  # $2 Package Version (optional)
  package="$1"
  version="$2"

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
  url=`python parse-json.py "$cache/python-tmp/$package/$package.json"`
  `"$wget" --quiet $url -P "$cache/python-tmp/$package"`
  cd "$cache/python-tmp/$package"
  IFS='.' read -a kind <<< "${url}"

  ext=${kind[${#kind[@]}-1]}
  if [ "$ext" == 'gz' ]; then
    tar zxf *.gz
  elif [ "$ext" == 'zip' ]; then
    unzip -quiet *.zip
  fi

  dir "$data/assets/python/$package"

  # We weren't passed a version, so we'll just get it from the downloaded folder name
  if [ -z "$version" ]; then
    dir=`find "$cache/python-tmp/$package/"* -maxdepth 0 -type d`
    IFS='-' read -a parts <<< "${dir}"
    version=${parts[${#parts[@]}-1]}
  fi
  # Check to see if a setup.py file is there. If so, copy/rename the sub-directory
  # (because of how those packages are, well, pacakged)
  if [ -f "$cache/python-tmp/$package/$package-$version/setup.py" ]; then
    cp -R "$cache/python-tmp/$package/$package-$version/$package" "$data/assets/python/$package/"
    mv "$data/assets/python/$package/$package" "$data/assets/python/$package/$version"
  else
    cp -R "$cache/python-tmp/$package/$package-$version" "$data/assets/python/$package/"
    mv "$data/assets/python/$package/$package-$version" "$data/assets/python/$package/$version"
  fi
    # if [ -f "$dir/setup.py" ]; then


  # fi

  cd - > /dev/null

  findGetRequirements $package $version

}

findGetRequirements() {
  # $1 Package Name
  # $2 Package Version (optional)
  package="$1"
  version="$2"

  if [ -z $version ]; then
    dir=`find "$cache/python-tmp/$package/"* -maxdepth 0 -type d`
  else
    dir="$cache/python-tmp/$package/$package-$version"
  fi

  if [ -f "$dir/requirements.txt" ]; then
    while read line
    do
      if [[ "$line" =~ (\=\=) ]]; then
        IFS='==' read -a req <<< "$line"
        for element in "${req[@]}"
        do
          if [ ! -z "$element" ]; then
            if [[ "$element" =~ ([a-z]{1,}) ]]; then
              package="$element"
            elif [[ "$element" =~ ([0-9\.]{1,}) ]]; then
              version="$element"
            fi
            if [ `checkPackage $package $version` == 'no' ]; then
              getPackage $package $version
            fi
          fi
        done
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

checkPackage() {
  # $1 Package Name
  # $2 Package Version (optional)
  package="$1"
  version="$2"

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
    v=(`find "$data/assets/python/$package/"* -maxdepth 0 -type d`)
    if [[ ${#v[@]} -eq 0 ]]; then
      echo "no" # the directory is there but with no versions
    elif [[ ${#v[@]} -eq 1 ]]; then
      echo $v
    else
      f="${v[${#v[@]}-1]}" # This should be the newest directory
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

if [ `checkPackage $1 $2` == 'no' ]; then
  getPackage $1 $2
fi


constructLinks() {
#   place holder
a=1
}


# So, since I'm doing this incredibly recursively, I'll need to create some tmp
# files to make sure that I move everything into the right place afterward.
