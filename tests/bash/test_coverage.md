#### Math (100%)

* Math::Plus
  * Covered by `plus_test`
* Math::Minus
  * Covered by `minus_test`
* Math::Times
  * Covered by `times_test`
* Math::Divide
  * Covered by `divide_test`
* Math::Floor
  * Covered by `floor_test`
* Math::Round
  * Covered by `round_test`
* Math::Mod
  * Covered by `mod_test`
* Math::Abs
  * Covered by `abs_test`
* Math::LT
  * Covered by `lt_test`
* Math::GT
  * Covered by `gt_test`
* Math::Equals
  * Covered by `equals_test`
* Math::Min
  * Covered by `min_test`
* Math::Max
  * Covered by `max_test`
* Math::Mean
  * Covered by `mean_test`
* Math::hex_to_dec
  * Covered by `hex_to_dec_test`
* Math::dec_to_hex
  * Covered by `dec_to_hex_test`

#### Icons (100%)

* AlfredBundler::icon
  * Covered by `download_icon_test`
  * Covered by `download_icon_alter_test`
  * Covered by `download_icon_hex_3_test`
* AlfredBundler::check_hex
  * Covered by `download_icon_test`
  * Covered by `download_icon_alter_test`
  * Covered by `download_icon_hex_3_test`
* AlfredBundler::alter_color
  * Covered by `download_icon_alter_test`
* AlfredBundler::get_background
  * Covered by `download_icon_alter_test`
* AlfredBundler::get_background_from_env
  * Covered by `get_background_from_env_test`
* AlfredBundler::get_background_from_util
  * Covered by `get_background_from_util_test`
* AlfredBundler::rgb_to_hsv
  * Covered by `recursive_color_test`
  * Covered by `download_icon_alter_test`
* AlfredBundler::hsv_to_rgb
  * Covered by `recursive_color_test`
  * Covered by `download_icon_alter_test`
* AlfredBundler::hex_to_rgb
  * Covered by `recursive_color_test`
  * Covered by `download_icon_alter_test`
* AlfredBundler::rgb_to_hex
  * Covered by `recursive_color_test`
  * Covered by `download_icon_alter_test`
* AlfredBundler::get_luminance
  * Covered by `download_icon_alter_test`
  * Covered by `get_background_from_env_test`
* AlfredBundler::get_brightness
  * Covered by `download_icon_alter_test`
  * Covered by `get_background_from_env_test`


#### Logging (100%)
_At least, all returned values are possible. Cannot programmatically check actual logging functions_

* AB::Log::normalize_log_level
  * Covered by `check_level_string`
  * Covered by `check_level_int`
  * Covered by `check_bad_level_string`
  * Covered by `check_bad_level_int`
* AB::Log::normalize_destination
  * Covered by `normalize_destination_test`
  * Covered by `normalize_destination_fail_test`

###### Not tested:
* AlfredBundler::Log
* AB::Log::Log
* AB::Log::Console
* AB::Log::File
* AB::Log::Setup
* AB::Log::Rotate



#### AlfredBundler.sh / alfred.bundler.sh

* AlfredBundler::load
  * Covered by `load_test`
  * Covered by `library_load_test`
  * Covered by `utility_load_test`
* AlfredBundler::utility
  * Covered by `utility_load_test`
* AlfredBundler::library
  * Covered by `library_load_test`

_Note: all are tested if you set the `full_tests` flag to "TRUE"_