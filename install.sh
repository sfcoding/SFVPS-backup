#!/bin/bash

# if cpan is too heavy for your host try using cpanm
# depends on megatools 1.9.97

sudo apt-get install libmysqlclient-dev
sudo cpan YAML Config::Simple DBI DBD::mysql Capture::Tiny
sudo apt-get -y install build-essential libglib2.0-dev libssl-dev \
    libcurl4-openssl-dev libgirepository1.0-dev
