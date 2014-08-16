#!/bin/bash

declare -r ME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

. "${ME}/../../bundler/AlfredBundler.sh"

# echo $(Math::Fmod '3.22' '1.2')

hex1="12ffed"
echo "Hex: #"$hex1
rgb=$(AlfredBundler::hex_to_rgb $hex1)
echo "RGB:" $rgb
hsv=$(AlfredBundler::rgb_to_hsv ${rgb})
echo "HSV ${hsv}"
rgb=$(AlfredBundler::hsv_to_rgb ${hsv})
echo "RGB ${rgb}"
hex2=$(AlfredBundler::rgb_to_hex ${rgb})
echo "Hex: #"$hex2