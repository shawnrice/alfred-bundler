<?php

class AlfredBundlerInternalClass {

    private $data;
    private $cache;
    private $major_version;
    private $plist;
    private $bundle;

    public function __construct( $plist ) {

      $this->major_version = file_get_contents( __DIR__ . '/meta/version_major' );
      $this->minor_version = file_get_contents( __DIR__ . '/meta/version_minor' );

      $this->data   = trim( "{$_SERVER[ 'HOME' ]}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-{$this->major_version}" );
      $this->cache  = trim( "{$_SERVER[ 'HOME' ]}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-{$this->major_version}" );
      $this->plist  = $plist;
      $this->bundle = exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$this->plist}'" );

    }


    public function icon( $name, $font, $color ) {
      $iconServers = explode( PHP_EOL, file_get_contents( __DIR__ . "/meta/icon_servers" ) );
      $iconDir = "{$this->data}/data/assets/icons";
      $iconPath = "{$iconDir}/{$font}/{$color}/{$name}.png";

      // If the icon has already been downloaded, then just return the path
      if ( file_exists( $iconPath ) )
        return $iconPath;

      if ( ! file_exists( "{$iconDir}/{$font}/{$color}" ) )
        mkdir( "{$iconDir}/{$font}/{$color}", 0775, TRUE );

      foreach( $iconServers as $server ) :
        // test the server somehow....
      endforeach;

      $success = $this->download( "{$server}/icon/{$font}/{$color}/{$name}", $iconPath );

      if ( $success === TRUE )
        return $iconPath;
      return false;


      // Rewrite to a proper cURL request
          $icon = file_get_contents( "$bd_icon_server_url/$font/$color/$icon" );
          if ( $icon === FALSE )
            die( 'Failed to get icon' ); // Problem getting icon

          file_put_contents( $path, $icon );

          // We have the icon file. It's saved, so just send the path back now.
          return $path;

    }

    public function utility( $name, $version, $json = '' ) {

    }

    public function library( $name, $version, $json = '' ) {

    }

    // How am I going to do this?
    public function composer( $packages ) {
      $composerDir = "{$this->data}/data/assets/php/composer";
      if ( ! file_exists( $composerDir ) )
        mkdir( $composerDir, 0755, TRUE );

      if ( ! file_exists( "{$composerDir}/composer.phar" ) )
        $this->download( "https://getcomposer.org/composer.phar", "{$composerDir}/composer.phar" );
        // Add check to make sure the that file is complete above...

      if ( file_exists( "{$composerDir}/bundles/{$this->bundle}/autoload.php" ) )
        require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
      else {
        if ( $this->installComposerPackage( $packages ) === TRUE )
          require_once( "{$composerDir}/bundles/{$this->bundle}/autoload.php" );
          return TRUE;
        else {
          // Do some sort of log and throw an error
          return FALSE;
        }
      }
    }

    /**
     * [installComposerPackage description]
     * @param {array} $json list of composer ready packages with versions
     * @TODO: Write this damn function
     */
    private function installComposerPackage( $packages ) {

// Process
// php composer.phar install -d "/Users/Sven/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/php/composer/tmp"
// Composer could not find a composer.json file in /Users/Sven/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-devel/data/assets/php/composer/tmp
// So, here is the install recipe:
// (1) create cache install dir --
// (2) create composer.json file in that dir
// (3) run 'php composer.phar install' on that composer.json file
// (4) rename all packages and extensions to (get the versions from vendor/composer/installed.json)
//     (a) vendor/{$VENDOR}/{$PACKAGE}-{$VERSION}
//     (b) extensions/{$EXTENSION}-{$VERSION} ----- OR WE DON'T SUPPORT EXTENSIONS HERE -- YES!
// (5) move vendor/composer to bundles/{$BUNDLEID}/composer
// (6) move vendor/autoload.php to bundles/{$BUNDLEID}/autoload.php
// (6) Alter the following files:
        // autoload_psr4.php
        // autoload_namespaces.php
        // autoload_files.php
        // autoload_classmap.php
  // (a) Change $vendorDir and $baseDir in each.
  // (b) Alter $vendorDir . '$vendor/$package' to '$vendor/$package-$version' in each

// $installDir = "{$this->cache}/{$this->bundle}/composer";
// Step #1
// if ( ! file_exists( $installDir ) )
//   mkdir( "{$installDir}/composer", 0775, TRUE )
//
// Step #2
// $json = json_encode( array( "require" => $packages ) );
// file_put_contents( "{$installDir}/composer.json", $json );
//
// Step #3
// $cmd = "php '{$this->data}/data/assets/php/composer/composer.phar' install -q -d '{$installDir}'";
// exec( $cmd );

    }

    public function load() {
      return $this->bundle;
    }

    private function readPlist( $plist, $key ) {
      if ( ! file_exists( $plist ) )
        return FALSE;

      return exec( "/usr/libexec/PlistBuddy -c 'Print :bundleid' '{$plist}'" );
    }

    public function download( $url, $file, $timeout = '3' ) {
      // Check the URL here

      // Make sure that the download directory exists
      if ( ! ( file_exists( dirname( $file ) ) && is_dir( dirname( $file ) ) ) )
        return FALSE;

      $ch = curl_init( $url );
      $fp = fopen( $file , "w");

      curl_setopt_array( $ch, array(
        CURLOPT_FILE => $fp,
        CURLOPT_HEADER => FALSE,
        CURLOPT_FOLLOWLOCATION => TRUE,
        CURLOPT_CONNECTTIMEOUT => $timeout
      ) );


      // Curl error codes: http://curl.haxx.se/libcurl/c/libcurl-errors.html
      if ( curl_exec( $ch ) === FALSE ) {
        curl_close( $ch );
        fclose( $fp );
        return curl_error( $ch) ;
      }

      curl_close( $ch );
      fclose( $fp );
      return TRUE;
    }




    private function installAsset( $json, $version ) {
      if ( ! file_exists( $json ) ) {
        echo "Error: cannot install asset because the JSON file is not present";
        return FALSE;
      }

      // @TODO: Add error checking to make sure that the file is good JSON
      $json = json_decode( file_get_contents( $json ) );

      $installDir = "{$this->data}/data/assets/{$json->type}/{$json->name}/{$version}";
      // Make the installation directory if it doesn't exist
      if ( ! file_exists( $installDir ) )
        mkdir( $installDir, 0775, TRUE );

      // Make the temporary directory
      $tmpDir = "{$this->cache}/installers";
      if ( ! file_exists( $tmpDir ) )
        mkdir( $tmpDir, 0775, TRUE );

// if ( file_exists( $json ) ) {
//  $json = file_get_contents( $json );
// }
//
// $json = json_decode( $json , TRUE );
// $name = $json[ 'name' ];
// $type = $json[ 'type' ];
//
// // Check to see if the version asked for is in the json; else, fallback to
// // default if exists; if not, throw error.
// if ( ! isset( $json[ 'versions' ][ $version ] ) ) {
//  if ( ! isset( $json[ 'versions' ][ 'default' ] ) ) {
//   echo "BUNDLER ERROR: No version found and cannot fall back to 'default' version!'";
//   return FALSE;
//  } else {
//   $version = 'default';
//  }
// }
// $invoke  = $json[ 'versions' ][ $version ][ 'invoke' ];
// $install = $json[ 'versions' ][ $version ][ 'install' ];
//
// // Download the file(s).
// foreach ( $json[ 'versions' ][ $version ][ 'files' ] as $url ) {
//  $file = __doDownload( $url[ 'url' ] );
//  if ( $file == '5' ) return FALSE;
//  // File not found on the internets... DIE.
//  if ( $url['method'] == 'zip' ) {
//   // Unzip the file into the cache directory, silently.
//   exec( "unzip -qo '$__cache/$file' -d '$__cache'" );
//  } else if ( $url['method'] == 'tgz' || $url['method'] == 'tar.gz' ) {
//   // Untar the file into the cache directory, silently.
//   exec( "tar xzf '$__cache/$file' -C '$__cache'");
//  }
// }
// $file = pathinfo( parse_url( "$url", PHP_URL_PATH ) );
// if ( is_array( $install ) ) {
//  foreach ( $install as $i ) {
//   // Replace the strings in the INSTALL json with the proper values.
//   $i = str_replace( "__FILE__"  , "$__cache/$file" , $i );
//   $i = str_replace( "__CACHE__" , "$__cache" , $i );
//   $i = str_replace( "__DATA__"  , "$__data/data/assets/$type/$name/$version/", $i );
//   exec( "$i" );
//  }
// }

      $url = $json->versions->$version->files->url;
      $file = pathinfo( parse_url( "$url", PHP_URL_PATH ) );
      $success = $this->download( $url, "{$tmpDir}/{$file}" );


    }

    /**
     * Prepends a datestamped message to a log file
     *
     * @param  {string} $log     path to log file
     * @param  {string} $message message to write to log
     * @return {[type]}          [description]
     */
    private function log( $log, $message ) {
      // Set date/time to avoid warnings/errors.
      if ( ! ini_get('date.timezone') ) {
        $tz = exec( 'tz=`ls -l /etc/localtime` && echo ${tz#*/zoneinfo/}' );
        ini_set( 'date.timezone', $tz );
      }

      if ( ! file_exists( $log ) ) {
        if ( ! file_exists( dirname( $log ) ) )
          mkdir( dirname( $log ), 0775, TRUE );
          $file = array();
      } else {
        // This is needed because, Macs don't read EOLs well.
        if ( ! ini_get( 'auto_detect_line_endings' ) )
          ini_set( 'auto_detect_line_endings', TRUE );

        $file = file( $log );
        // @TODO: set variable for max log length
        // Check if the logfile is longer than 500 lines. If so, then trim the
        // last 50 of those.
        if ( count( $file ) >= 500 ) {
          for ( $i = 450, $i < 500, $i++ ) :
            unset( $file[ $i ] );
          endfor;
        }

      }

      $message = date( "D M d H:i:s T Y -- " ) . $message;
      array_unshift( $file, $message );

      file_put_contents( $log, implode( '', $file ) );
    }


}


// Also get packages from https://packagist.org/
// To do this, we have to use composer, but I'm not exactly sure how....

// for composer... (1) download composer as a utility
//

$composer = array(


);

// {
//     "name": "you/themename",
//     "type": "wordpress-theme",

//     "extra": {
//         "installer-paths": {
//             "sites/example.com/modules/{$name}": ["vendor/package"]
//         }
//     }
// }

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
