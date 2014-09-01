#!/usr/bin/python
# encoding: utf-8
from __future__ import unicode_literals

import re
import sys
import imp
import os.path
import subprocess

HOME = os.path.expanduser("~")
LIB_PATH = os.path.join(HOME, "Library/Application Support/Alfred 2/" \
                        "Workflow Data/alfred.bundler-aries/assets/python/")


def as_run(ascript):
    """Run the given AppleScript and return the standard output and error."""
    osa = subprocess.Popen(['osascript', '-'],
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE)
    return osa.communicate(ascript)[0].strip()


def _pip_install():
    """If `pip` isn't installed, install it"""
    try:                    # Check if `pip` installed
        imp.find_module('pip')
        return True
    except ImportError:     # If not installed, install it
        get_pip = """do shell script "python '{0}/get-pip.py'" """.format(
            LIB_PATH)
        return as_run(get_pip)

def _get_version(_path):
    """Return version number of package"""
    egg_file = [v for v in os.listdir(_path) if v.endswith('.egg-info')][0]
    _egg = os.path.join(_path, egg_file)
    _info = os.path.join(_egg, 'PKG-INFO')
    with open(_info, 'r') as _file:
        data = _file.read()
        _file.close()
    try:
        _version = re.search(r"^Version:\s(.*?)$", data, re.M).group(1)
    except TypeError:
        _version = '0.0'
    return _version

def _pkg_exists(_pkg, _version=None):
    """Check if `pkg` in bundler"""
    if _pkg in os.listdir(LIB_PATH):
        pkg_path = os.path.join(LIB_PATH, _pkg)

        if _version == None:
            _versions = [v for v in os.listdir(pkg_path) if v != '.DS_Store']
            if len(_versions) == 1:     # return only version
                return os.path.join(pkg_path, _versions[0])
            elif len(_versions) > 1:    # return highest version
                return os.path.join(pkg_path, max(_versions))
            elif len(_versions) == 0:   # return package path
                return pkg_path
        else:
            _versions = [v for v in os.listdir(pkg_path) if v == _version]
            if len(_versions) == 1:
                return os.path.join(pkg_path, _versions[0])
            elif len(_versions) == 0:
                return True
    else:
        return True

def _pkg_path(_pkg, sub_dir):
    """Return full path to `pkg`'s sub directory"""
    sub_dir = os.path.join(_pkg, sub_dir)
    return os.path.join(LIB_PATH, sub_dir)


def __load(_pkg, _version=None):
    """Load `pkg` in bundler"""
    # ensure `pip` is installed
    _pip_install()

    # is `package` installed?
    _status = _pkg_exists(_pkg, _version)
    
    if _status != True:     # if `pkg` in bundler, return path
        return _status
    else:                   # else, install `pkg`
        if _version == None:
            install_path = _pkg_path(_pkg, 'tmp')
            install_scpt = """
                do shell script "sudo pip install --target='{path}' {pkg}" \
                with administrator privileges
            """.format(
                path=install_path,
                pkg=_pkg
                )
            as_run(install_scpt)

            _version = _get_version(install_path)
            new_path = _pkg_path(_pkg, _version)

            rename_scpt = """
                do shell script "sudo mv '{old}' '{new}'" \
                with administrator privileges
            """.format(
                old=install_path,
                new=new_path
                )
            as_run(rename_scpt)
            return new_path

        else:
            install_path = _pkg_path(_pkg, _version)
            install_scpt = """
                do shell script "sudo pip install --target='{path}' {pkg}=={vers}" \
                with administrator privileges
            """.format(
                path=install_path,
                pkg=_pkg,
                vers=_version
                )

            as_run(install_scpt)
            return install_path


def main():
    """Test case"""
    pkg_path = __load('html2text')
    sys.path.insert(0, pkg_path)
    import html2text
    print html2text
    

if __name__ == '__main__':
    main()
