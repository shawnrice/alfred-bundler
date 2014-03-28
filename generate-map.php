<?php

// generate_map.php
$user = exec('echo $USER');
$data = "/Users/$user/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler/assets";
$packages = array();
$d = scandir("$data/python");

foreach ( $d as $k => $v ) {
  if (! is_dir("$data/python/$v")) {
    unset($d[$k]);
  } else if ( ($v == ".") || ($v == ".." ) ) {
    unset($d[$k]);
  } else {
    $packages["$v"] = array();
  }
}

foreach ( $packages as $p => $null ) {
  $d = scandir("$data/python/$p");
    foreach ( $d as $k => $v ) {
      if (! is_dir("$data/python/$p/$v")) {
        unset($d[$k]);
      } else if ( ($v == ".") || ($v == ".." ) ) {
        unset($d[$k]);
      } else {
        $packages["$p"][] = $v;
      }
    }
}

ksort($packages);

foreach ( $packages as $p => $null ) {
  rsort( $packages[$p] , SORT_NUMERIC );
}

$packages = json_encode($packages);
file_put_contents( "$data/python/map.json", $packages );
