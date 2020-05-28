#!/bin/bash

DIR=${0%/*}

source $DIR/env

send_mail() {
    read subject
    mutt -s "${subject:-"最新章节"}" \
        -e "set content_type=text/html" \
        $rcpt
}

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
