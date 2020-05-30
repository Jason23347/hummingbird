#!/bin/bash

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
