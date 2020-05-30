#!/bin/bash

DIR=${0%/*}

source $DIR/env

# using mutt to sned mail
source $DIR/mail/mutt/utils

# autoload config
ls $DIR/$conf_dir | while read conf; do
    # load settings
    source $DIR/$conf_dir/$conf
    source $DIR/$driver_dir/$driver/utils
    source $DIR/$template_dir/$template/utils

    # scheduled tasks
    check_list
    [ $? -eq 0 ] &&
        fetch_page $name | pack_up | send_mail
done
