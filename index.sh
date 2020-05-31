#!/bin/bash
#
# Hummingbird - A bash framework for novel crawlers
# Copyright (C) 2020    Jason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

DIR=${0%/*}

source $DIR/env

# using mutt to sned mail
source $DIR/mail/mutt/utils
[ $debug -gt 0 ] && {
    unset send_mail
    send_mail() {
        tee
    }
}

# autoload config
ls $DIR/$conf_dir | while read conf; do
    # load settings
    source $DIR/$conf_dir/$conf
    source $DIR/$driver_dir/$driver/utils
    source $DIR/$template_dir/$template/utils

    # scheduled tasks
    [ $debug -gt 0 ] || check_list
    [ $debug -gt 1 ] || [ $? -eq 0 ] &&
        fetch_page $name | pack_up | send_mail
done
