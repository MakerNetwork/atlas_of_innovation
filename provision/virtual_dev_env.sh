#!/usr/bin/env bash

###
# Update system packages
system_update() {
  echo "Updating box software ************************************************ "
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y tree
}

###
# Set vagrant user settings
set_user_conf() {
  echo "Setting vagrant user configuration *********************************** "
  # Generate language files
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8

  # Set language with env variables
  echo -e '\n# Set locale configuration' >> ~/.bashrc
  echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
  echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
  echo -e 'export LANGUAGE=en_US.UTF-8\n' >> ~/.bashrc

  # Move to the sync folder at login
  echo -e '\n# Move to /vagrant at login' >> ~/.bashrc
  echo -e 'cd /vagrant\n' >> ~/.bashrc
}

###
# Install and configure PostgreSQL database manager
install_postgres() {
  echo "Installing PostgreSQL database manager ******************************* "
  sudo apt-get install -y postgresql postgresql-contrib

  echo "Setting up user"
  sudo -u postgres bash -c "psql -c \"CREATE USER ubuntu WITH PASSWORD 'ubuntu';\""
  sudo -u postgres bash -c "psql -c \"ALTER USER ubuntu WITH SUPERUSER;\""

  echo "Setting up extensions to all schemas"
  sudo -u postgres bash -c "psql -c \"CREATE EXTENSION unaccent SCHEMA pg_catalog;\""
  sudo -u postgres bash -c "psql -c \"CREATE EXTENSION pg_trgm SCHEMA pg_catalog;\""

  echo " Starting Postgres server "
  sudo service postgresql start
}

###
# Create database for the application
create_database() {
  echo "Creating application database **************************************** "
  sudo -u postgres bash -c "psql -c \"CREATE DATABASE atlas;\""
}

###
# Install Python dependencies
install_python_deps() {
  echo "Installing Python dependencies *************************************** "
  sudo apt-get install -y build-essential \
    python3-dev \
    python3-pip \
    libffi-dev
}

###
# Define a Python virtual environment
set_virtual_env(){
  echo "Setting Python virtual enviroment ************************************ "
  sudo -H pip3 install -U pip
  sudo -H pip3 install virtualenv virtualenvwrapper

  mkdir ~/Python-Env

  echo -e "\n# Set environment root directory" >> ~/.bashrc
  echo "export WORKON_HOME=~/Python-Env" >> ~/.bashrc
  echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
  echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
}

###
# Install app dependencies with pip
install_app_deps() {
  echo "Installing app pip dependencies ************************************** "
  export WORKON_HOME=~/Python-Env
  export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
  source /usr/local/bin/virtualenvwrapper.sh
  mkvirtualenv -a /vagrant -r /vagrant/requirements.txt atlas

  echo -e "\n# Load Python environment for Atlas" >> ~/.bashrc
  echo "workon atlas" >> ~/.bashrc
}

###
# Install NginX webserver
install_nginx() {
  echo "Installing NginX webserver ******************************************* "
  sudo apt-get install -y nginx
}

###
# Fetch basic nginx configuration
fetch_nginx_conf() {
  echo 'Fetching basic nginx configuration *********************************** '
  sudo mv ~/nginx.conf /etc/nginx/sites-available/atlas.conf
  sudo ln -s /etc/nginx/sites-available/atlas.conf /etc/nginx/sites-enabled/atlas.conf
  sudo nginx -s reload
}

###
# Install DirEnv env values manager
install_direnv() {
  echo "Installing DirEnv **************************************************** "
  mkdir ~/bin
  curl -sSL https://github.com/direnv/direnv/releases/download/v2.18.2/direnv.linux-amd64 > ~/direnv
  sudo mv ~/direnv /usr/local/bin/direnv
  chmod +x /usr/local/bin/direnv
  echo -e "\n# Hook direnv environment switcher"  >> ~/.bashrc
  echo -e "eval \"\$(direnv hook bash)\"\n" >> ~/.bashrc
}

###
# Fetch basic environment values
fetch_env_files() {
  echo 'Fetching basic environment values ************************************ '
  sudo mv ~/values.env /vagrant/.envrc

  echo -e "\n# Automatically allow changes to .envrc at login"  >> ~/.bashrc
  echo -e "direnv allow /vagrant\n" >> ~/.bashrc
}

###
# Include some alias to work with Atlas
add_command_alias() {
  echo "Include alias to manage Atlas **************************************** "
  echo -e "\n# Commands to help with Atlas management"
  echo "alias atlas-start='uwsgi --ini atlas.ini'" >> ~/.bashrc
  echo "alias atlas-stop='uwsgi --stop ~/atlas-master.pid'" >> ~/.bashrc
  echo "alias atlas-migrate='python ~/atlas_of_innovation/manage.py makemigrations && python ~/atlas_of_innovation/manage.py migrate'" >> ~/.bashrc
  echo "alias atlas-assets-regenerate='python manage.py collectstatic --clear'" >> ~/.bashrc
  echo "alias atlas-load-data='python ~/atlas_of_innovation/manage.py loaddata governance_options ownership_options initial_database'" >> ~/.bashrc
  echo "alias atlas-force-quit='sudo pkill -f uwsgi -9'" >> ~/.bashrc
  echo "alias atlas-db-prepare='/vagrant/bin/db_prepare.sh'" >> ~/.bashrc
  echo "alias atlas-db-reset='/vagrant/bin/db_reset.sh'" >> ~/.bashrc
}

###
# Remove unused and transient software
cleanup() {
  sudo apt-get -y autoremove && sudo apt-get autoclean
}

###
# Main function
setup(){
  system_update
  set_user_conf
  install_postgres
  create_database
  install_python_deps
  set_virtual_env
  install_app_deps
  install_nginx
  fetch_nginx_conf
  install_direnv
  fetch_env_files
  add_command_alias
  cleanup
}

setup "$@"
echo "The virtual environment has been provisioned. Run 'vagrant reload'."
