<?php


<?php
class AlfredBundlerInternalClass {
    public $a;

    private $data;
    private $cache;
    private $major_version;

    public function __construct() {

      $this->major_version = file_get_contents( __DIR__ . '/bundler/meta/version_major' );
      $this->minor_version = file_get_contents( __DIR__ . '/bundler/meta/version_minor' );

      $this->data  = "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}";
      $this->cache = "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}";

      $this->a = 'a';
    }

    public function getA() {
      return $this->major_version;
    }

    public function showfirst() {
      echo $this->major_version;
    }
}


// Also get packages from https://packagist.org/
// To do this, we have to use composer, but I'm not exactly sure how....

// OLD VERSION

// require_once( 'includes/registry-functions.php' );
// require_once( 'includes/install-functions.php' );

// $__data  = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
// $__cache = $_SERVER[ 'HOME' ] . "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version";
//
//
// if ( ! isset( $bundler_version ) ) {
//   // Define the global bundler versions.
//   $bundler_version       = trim( file_get_contents( "$__data/meta/version_major" ) );
//   $bundler_minor_version = trim( file_get_contents( "$__data/meta/version_minor" ) );
// }
//
// // Since this is a PHP bundler, we'll assume that the default type is PHP.
// function __loadAsset( $name , $version = 'default' , $bundle , $type = 'php' , $json = '' ) {
//
//   global $bundler_version;
//   $__data = $_SERVER[ 'HOME' ] . "/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version";
//
//   if ( $type == 'icon' ) { // Deal with icons first
//     // We didn't plan, originally, to have icons work with the bundler, so this is a bit of a hack.
//     // The next major version of the bundler will have better icon support.
//     if ( ! ( isset( $version ) && isset( $json ) ) ) // We need all the arguments here.
//       die( 'Need to pass all arguments' );
//
//     $icon               = $name;
//     $font               = $version;
//     $color              = $json;
//
//
//     $iconDir            = "$__data/assets/icons/$font/$color";
//     $path               = "$__data/assets/icons/$font/$color/$icon.png";
//
//     if ( file_exists( $path ) ) // See if the file is already there.
//       return $path;
//
//     if ( ! file_exists( $iconDir ) ) {
//       if ( ! mkdir( $iconDir, 0775, TRUE ) ) // Make the icon directory and those below it if necessary.
//         die( 'Failed to make directory' );
//     }
//
//     $bd_icon_server_url = 'http://icons.deanishe.net/icon';
//
//     // Rewrite to a proper cURL request
//     $icon = file_get_contents( "$bd_icon_server_url/$font/$color/$icon" );
//     if ( $icon === FALSE )
//       die( 'Failed to get icon' ); // Problem getting icon
//
//     file_put_contents( $path, $icon );
//
//     // We have the icon file. It's saved, so just send the path back now.
//     return $path;
//   }
//
//   if (   empty( $version ) ) $version = 'default'; // This shouldn't be needed....
//   if ( ! empty( $bundle  ) ) __registerAsset( $bundle , $name , $version );
//
//   // First: see if the file exists.
//   if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
//     // It exists, so just return the invoke parameters.
//     $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
//
//     if ( ( $type == 'utility' ) && ( ! empty( $invoke ) ) && ( $invoke != 'null' ) ) {
//       // Utilities should have only a single line invoke file, so that's
//       // just fine to consider it a string.
//
//       /////////////////////////////////////////////////////////////////////////////////
//       // Let's start the caching checks
//
//       $bd_asset_cache = "$__data/data/call-cache";
//
//       // Make sure the directory exists
//       if ( ! ( ( file_exists( $bd_asset_cache ) && is_dir( $bd_asset_cache ) ) ) )
//         mkdir( $bd_asset_cache );
//
//       // Cache path for this call
//       $key       = md5( "$name-$version-$type-$json" );
//       $cachepath =      "$bd_asset_cache/$key";
//
//       if ( file_exists( "$cachepath" ) ) {
//         $path = file_get_contents( "$cachepath" );
//         if ( file_exists( "$path" ) ) {
//           // The cache has been found, and we have the asset there already.
//           return array( $path );
//         }
//       }
//
//       // The cache hasn't been found, so we'll call gatekeeper
//       $invoke = str_replace("\n", '', $invoke);
//       if ( strpos( $invoke, '.app' ) !== FALSE ) {
//         // Invoke Gatekeeper only when the utility is a .app.
//         // ech
//
//         exec( "bash '$__data/includes/gatekeeper.sh' '$name' '$__data/assets/$type/$name/$version/$name.app'", $output, $return );
//         if ( $return !== 0 ) {
//           return $output[0];
//         } else if ( $return == 0 ) {
//           file_put_contents( "$bd_asset_cache/$key", "$__data/assets/$type/$name/$version/$invoke" );
//           return array( "$__data/assets/$type/$name/$version/$invoke" );
//         }
//       }
//     }
//
//     $invoke = explode( "\n" , $invoke );
//     foreach ( $invoke as $k => $v ) {
//       $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
//     }
//     return $invoke;
//   }
//
//   // Asset doesn't exist, so let's look to see if it's in the defaults.
//   if ( ! empty( $json ) ) {
//     // Since the json variable is not empty and the asset doesn't exist, we'll
//     // assume it's new.
//     __installAsset( $json , $version );
//   } else if ( file_exists( "$__data/meta/defaults/$name.json" ) && empty( $json ) ) {
//     $info = json_decode( file_get_contents( "$__data/meta/defaults/$name.json" ) , TRUE);
//     $versions = array_keys( $info[ 'versions' ] );
//     $json = file_get_contents( "$__data/meta/defaults/$name.json" );
//     if ( in_array( $version , $versions ) ) {
//       __installAsset( $json , $version );
//     }
//   }
//
//   // Let's try this again.
//   if ( file_exists( "$__data/assets/$type/$name/$version/invoke" ) ) {
//     // It exists, so just return the invoke parameters.
//     $invoke = file_get_contents( "$__data/assets/$type/$name/$version/invoke" );
//     $invoke = explode( "\n" , $invoke );
//     foreach ( $invoke as $k => $v ) {
//       if ( $v == 'null' ) {
//         // Certain utilities might request only the basepath (i.e. Pashua) to be
//         // invoked. To get around empty 'invoke' files that might trigger errors,
//         // they are populated with the contents 'null' that we need to replace
//         // with nothing.
//         $v = '';
//       }
//       $invoke[$k] = "$__data/assets/$type/$name/$version/$v";
//     }
//     return $invoke;
//   }
//   // We shouldn't be here, but we'll do this anyway; well, an invalid asset was called.
//   echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know.";
//   return FALSE;
//
// } // End loadAsset()
