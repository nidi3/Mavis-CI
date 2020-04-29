#!/bin/bash

install_jdk() {
  set -e
  echo "running ${TRAVIS_OS_NAME}-specific configuration"
  export JAVA_HOME="$HOME/.jabba/jdk/$JDK"
  _pre_jdk
  export PATH="$JAVA_HOME/bin:$PATH"
  # Apparently exported variables are ignored in subsequent phases on Windows. Write in config file
  echo "export JAVA_HOME=\"${JAVA_HOME}\"" >>~/.env
  echo "export PATH=\"${PATH}\"" >>~/.env
  _jabba_jdk
  which java
  java -Xmx32m -version
  set +e
}

install_maven() {
  VERSION=${1:-3.6.3}
  TARGET=$HOME/.m2
  case $TRAVIS_OS_NAME in
  "linux" | "osx")
    if [ ! -d "$TARGET" ]; then
      wget https://downloads.apache.org/maven/maven-3/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz
      tar -xf apache-maven-$VERSION-bin.tar.gz -C $TARGET
    fi
    export PATH=$TARGET/apache-maven-$VERSION/bin:$PATH
    ;;
  "windows")
    choco install maven
    export M2_HOME=$(ls -d /c/ProgramData/chocolatey/lib/maven/apache-maven-*/)
    export PATH="${M2_HOME}bin:$PATH"
    echo "export PATH=\"${PATH}\"" >>~/.env
    ;;
  *)
    echo unrecognized OS $TRAVIS_OS_NAME
    ;;
  esac
}

before_script() {
  mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V "$@"
}

script() {
  mvn test -B "$@"
}

_pre_jdk() {
  case $TRAVIS_OS_NAME in
  "linux")
    _unix_pre
    ;;
  "osx")
    _unix_pre
    export JAVA_HOME="$HOME/.jabba/jdk/$JDK/Contents/Home"
    ;;
  "windows")
    PowerShell -ExecutionPolicy Bypass -Command '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression (Invoke-WebRequest https://github.com/shyiko/jabba/raw/master/install.ps1 -UseBasicParsing).Content'
    export jabba="$HOME/.jabba/bin/jabba.exe"
    ;;
  *)
    echo unrecognized OS $TRAVIS_OS_NAME
    ;;
  esac
}

_unix_pre() {
  curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh
  unset _JAVA_OPTIONS
  export jabba=jabba
}

_jabba_jdk() {
  if $jabba use $JDK; then
    echo $JDK was available and Jabba is using it
  else
    echo installing $JDK
    $jabba install "$JDK" || exit $?
    echo setting $JDK as Jabba default
    $jabba use $JDK || exit $?
  fi
}
