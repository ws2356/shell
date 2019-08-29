tolower($0) ~ /dog/ {print "match line: " $0}  /dog$/ {print "match at line end: " $0}
