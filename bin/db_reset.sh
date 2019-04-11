#!/usr/bin/env bash

###
# Drops, recreates and loads the `atlas` database
reset_database() {
  sudo -u postgres bash -c "psql -c \"DROP DATABASE atlas;\""
  sudo -u postgres bash -c "psql -c \"CREATE DATABASE atlas;\""
  bash db_prepare.sh
}

reset_database "$@"
