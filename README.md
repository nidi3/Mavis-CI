# Mavis-CI
maven builds with linux/macos/windows on [Travis CI](https://travis-ci.org/).

Inspired by and thanks to 
- [DanySK](https://github.com/DanySK) for [Gravis-CI](https://github.com/DanySK/Gravis-CI) 
- [shyiko](https://github.com/shyiko) for [jabba](https://github.com/shyiko/jabba)

A base `.travis.yml` file looks like this:

    language: bash
    dist: xenial
    os:
      - linux
      - osx
      - windows
    
    env:
      - JDK="adopt@1.8.212-04"
    
    cache:
      directories:
        - $HOME/.m2
    
    before_install:
      - curl "https://raw.githubusercontent.com/nidi3/Mavis-CI/master/mavis.sh" --output mavis.sh
      - source mavis.sh
      - install_jdk
      - install_maven
    
    before_script:
      before_script
    
    script:
      script

