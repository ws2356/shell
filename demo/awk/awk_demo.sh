#! /usr/bin/env bash

awk '
BEGIN { hasBegan = 0 }
{
	if (hasBegan == 0) {
		for (ii = 1; ii <= NF; ii += 1) {
			arr[ii] = $ii;
		}
		hasBegan = 1;
	} else {
		for (ii = 1; ii <= NF; ii += 1) {
			arr[ii] = arr[ii]" "$ii;
		}
	}
}
END {
	for (ii = 1; ii <= length(arr); ii += 1) {
		print arr[ii];
	}
}
' file.txt

