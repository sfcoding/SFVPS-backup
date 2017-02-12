#!/bin/bash
sudo apt-get install libmysqlclient-dev
cpan Config::Simple DBI DBD::mysql Capture::Tiny
