<?php


require_once( __DIR__ . '/../../bundler/bundlets/alfred.bundler.php' );

$_ENV['AB_BRANCH'] = 'devel';
$_ENV[''] = '';
$_ENV[''] = '';
$_ENV[''] = '';

$b = new AlfredBundler;
$i = new AlfredBundlerIcon;
