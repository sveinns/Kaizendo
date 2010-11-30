#!/bin/sh

# Deploy script for Kaizendo on a temporary schroot
# Copyright (C) 2010 Stig Sandbeck Mathisen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Requirements:
#
# - a schroot called "lucid", with user and root access
#
# - a CPAN configuration file for your application user specifiying
#   the use of "sudo" to install perl modules
#
# - Passwordless sudo access for this application user

session=$(schroot -c lucid -b)
appdir=$(mktemp -u -d /var/tmp/kaizendogfood.XXXXXXXX)

install_dev_environment() {
    echo "### Installing development environment"

    modules="Catalyst::Devel DBIx::Class Module::Install
        Module::Install::AuthorRequires SQL::Translator est::EOL
        Test::NoTabs Test::Pod Test::Pod::Coverage"

    rm -fr ~/.cpan/build

    schroot -c $session -r -- env PERL_MM_USE_DEFAULT=1 cpan -i ${modules}
}

clone_appdir() {
    echo "### Cloning application"
    schroot -c $session -r -- git clone https://github.com/sjn/Kaizendo.git ${appdir}
}

install_app_dependencies() {
    echo "### Installing application dependencies"
    if cd ${appdir}
    then
	schroot -c $session -r -- env PERL_MM_USE_DEFAULT=1 cpan -i .
    else
	echo "Error: Could not cd to ${appdir}"
	return 1
    fi
}

run_app() {
    echo "### Running application"
    if cd ${appdir}
    then
	schroot -c ${session} -r -- script/kaizendo_server.pl
    else
	echo "Error: Could not cd to ${appdir}"
	return 1
    fi
}

fail() {
    echo "### Failed.  Manual cleanup required for schroot '${session}'"
    exit 1
}

install_dev_environment  || fail
clone_appdir             || fail
install_app_dependencies || fail
run_app                  || fail

echo "### Finished.  Manual cleanup required for schroot '${session}'"