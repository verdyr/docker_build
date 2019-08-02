#!/bin/bash
# operator-sdk env setup

mkdir -p $HOME/go/bin
export PATH=$PATH:$HOME/go/bin
export GOBIN=$HOME/go/bin

mkdir -p $GOPATH/src/github.com/operator-framework
cd $GOPATH/src/github.com/operator-framework
git clone https://github.com/operator-framework/operator-sdk

curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
cd operator-sdk && git checkout master && make dep && make install

echo "done, check any operator code or go to confirm"
