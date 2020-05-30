{
    # end with "---"
    if (match($0, "---"))
        exit 0

    # skip first line
    if (NR == 1) {
        print $0
        next
    }

    print "<p style=\"font-size: 25px;\">"$0"</p>"
}