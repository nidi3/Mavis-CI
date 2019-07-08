#!/bin/bash
case $TRAVIS_OS_NAME in
    "linux")
        sudo apt-get -qq update
        sudo apt-get install maven=$MAVEN_VERSION
        ;;
    "osx")
        echo Maven is apparently pre-installed on Travis OSX image
        ;;
    "windows")
        choco install maven --version $MAVEN_VERSION
        ;;
    *)
        echo unrecognized OS $TRAVIS_OS_NAME
        ;;
esac
