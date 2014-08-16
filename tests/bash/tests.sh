#!/bin/bash

declare -r ME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

. "${ME}/../../bundler/AlfredBundler.sh"




# echo $(Math::Fmod '3.22' '1.2')

# hex1="12ffed"
# echo "Hex: #"$hex1
# rgb=$(AlfredBundler::hex_to_rgb $hex1)
# echo "RGB:" $rgb
# hsv=$(AlfredBundler::rgb_to_hsv ${rgb})
# echo "HSV ${hsv}"
# rgb=$(AlfredBundler::hsv_to_rgb ${hsv})
# echo "RGB ${rgb}"
# hex2=$(AlfredBundler::rgb_to_hex ${rgb})
# echo "Hex: #"$hex2

###############################################################################
#### Log Tests

function check_level_string {
    a=1
}

function check_level_int {
    a=1
}

function check_bad_level_string {
    a=1
}

function check_bad_level_int() {
    a=1
}


###############################################################################
#### Math Tests (the child in me shudders)
# We'll check to make sure that our functions output the same
# as the logic in a PHP function does (i.e. check our floating
# point math in a language that doesn't do it against one that
# does).


# a little function to check on things...
function check_result() {
    if [[ $1 == $2 ]]; then
        echo true
    else
        echo -n " (Bash: $1 PHP: $2)" >&2
        echo false
    fi
}


# Generate numbers for testing
function rfloat() {
    echo $(php -r "echo mt_rand(0,100*100000)/100000;")
}

function rhex() {
    echo $(php -r 'echo sprintf("%02x", mt_rand(0, 0xff));')
}

# To strip trailing 0's and make sure values where -1 < x < 1 have 0's before the decimal
function normalize() {
    bash=$1
    bash=${bash%%0} # delete trailing 0's
    [[ ${bash:0:1} == '.' ]] && bash=0${bash}
    if [ ${bash:0:2} == '-.' ]; then
        bash=-0${bash:1:${#bash}-2}
    fi
    echo $bash
}

function plus_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Plus $one $two)
    bash=$(normalize $bash)
    php=$(php -r "echo round($one + $two, 10, PHP_ROUND_HALF_DOWN);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function minus_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Minus $one $two)
    bash=$(normalize $bash) # remove trailing 0's add first 0 if necessary
    php=$(php -r "echo round($one - $two, 10, PHP_ROUND_HALF_DOWN);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function times_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Times $one $two)
    bash=$(normalize $bash)
    php=$(php -r "echo round($one * $two, 10, PHP_ROUND_HALF_DOWN);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function divide_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Divide $one $two)
    bash=$(normalize $bash)
    php=$(php -r "echo round($one / $two, 10, PHP_ROUND_HALF_DOWN);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function mod_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Mod $one $two)
    bash=$(normalize $bash)
    php=$(php -r "echo round(fmod($one, $two), 10, PHP_ROUND_HALF_DOWN);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function floor_test() {
    one=$(echo $(rfloat))
    bash=$(Math::Floor $one)
    php=$(php -r "echo floor($one);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function round_test() {
    one=$(echo $(rfloat))
    bash=$(Math::Round $one)
    php=$(php -r "echo round($one, 0);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function abs_test() {
    one=$(echo $(rfloat))
    bash=$(Math::Abs $one)
    bash=$(normalize $bash)
    php=$(php -r "echo abs($one);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function gt_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::GT $one $two)
    php=$(php -r "echo $one > $two;")
    [[ -z $php ]] && php="0"
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function lt_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::LT $one $two)
    php=$(php -r "echo $one < $two;")
    [[ -z $php ]] && php="0"
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function equals_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    bash=$(Math::Equals $one $two)
    php=$(php -r "echo $one == $two;")
    [[ -z $php ]] && php="0"
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function min_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    three=$(echo $(rfloat))
    bash=$(Math::Min $one $two $three)
    php=$(php -r "echo min([$one, $two, $three]);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function max_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    three=$(echo $(rfloat))
    bash=$(Math::Max $one $two $three)
    php=$(php -r "echo max([$one, $two, $three]);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function mean_test() {
    one=$(echo $(rfloat))
    two=$(echo $(rfloat))
    three=$(echo $(rfloat))
    bash=$(Math::Mean $one $two $three)
    bash=$(normalize $bash)
    php=$(php -r "echo substr(round(array_sum([$one, $two, $three])/3,11),0,-1);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function hex_to_dec_test() {
    hex=$(rhex)
    bash=$(Math::hex_to_dec $hex)
    php=$(php -r "echo hexdec('$hex');")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function dec_to_hex_test() {
    dec=$(php -r "echo rand(0,255);")
    bash=$(Math::dec_to_hex $dec)
    bash=$(echo $bash | tr [[:upper:]] [[:lower:]]) #php uses lower
    php=$(php -r "echo dechex($dec);")
    [[ $(check_result $bash $php) == 'true' ]] && return 0 || return 1
}

function math_tests() {
    local passed=0
    local failed=0

    # Queue Tests
    local tests=()
    tests+=(plus_test)
    tests+=(minus_test)
    tests+=(times_test)
    tests+=(divide_test)
    tests+=(floor_test)
    tests+=(round_test)
    tests+=(mod_test)
    tests+=(abs_test)
    tests+=(lt_test)
    tests+=(gt_test)
    tests+=(equals_test)
    tests+=(min_test)
    tests+=(max_test)
    tests+=(mean_test)
    tests+=(hex_to_dec_test)
    tests+=(dec_to_hex_test)
    local num=${#tests[@]}

    echo "Starting Math Tests. Note: some might fail due to a slight rounding error"
    echo "========================================================================="

    # Do tests
    #
    for test in ${tests[@]}; do
        echo -n "Doing $test..."
        $test
        if [[ $? -eq 0 ]]; then
            echo " ...passed"
            passed=$(( passed + 1 ))
        else
            echo " ...failed"
            failed=$(( failed + 1 ))
        fi
    done
    echo "========================================================================="
    echo "Passed: ${passed} / ${num}"
    echo "Failed: ${failed} / ${num}"
}

###############################################################################
### End math tests
###############################################################################

AB::Log::Log "Testing" INFO both


# math_tests