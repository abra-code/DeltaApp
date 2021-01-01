#! /bin/bash

# this is the worker script comparing two files in orig and new dir
# it is supposed to be called by the CompareDirs.bash driver script

dir_orig="$1"
dir_new="$2"
rel_file="$3"
mode="$4"
size_delta_threshold="$5"

# The following string manipulations are bash tricks. See:
# http://linuxgazette.net/issue18/bash.html

# ${variable%pattern}
#    Trim the shortest match from the end
# ${variable##pattern}
#    Trim the longest match from the beginning
# ${variable%%pattern}
#    Trim the longest match from the end
# ${variable#pattern}
#    Trim the shortest match from the beginning

# trim first ./ suffix which "find" helpfully prepends to relative path
rel_file=${rel_file#\./}

# trim everyhting from the beginning up to last / (including)
file_name=${rel_file##*/}
# equivalent to file_name=$(basename "$rel_file");

# silently ignore .DS_Store files
if test "$file_name" = ".DS_Store"; then
	exit 0
fi

orig_file="$dir_orig/$rel_file"
#echo "orig_file: $orig_file"

new_file="$dir_new/$rel_file"
#echo "new_file: $new_file"

new_file_exists=yes
if test ! -f "$new_file"; then
	new_file_exists=no
else
	# both files are present
	# in "missing" or "missing_swapped" mode we skip
	if test "$mode" = "missing" -o "$mode" = "missing_swapped"; then
		exit 0
	fi
fi

orig_file_size=$(/usr/bin/stat -f%z "$orig_file")

new_file_size=0
if test "$new_file_exists" = yes; then
	new_file_size=$(/usr/bin/stat -f%z "$new_file")
fi

size_difference=$(expr "$new_file_size" - "$orig_file_size")
#echo "size_difference = $size_difference"

# if below size difference threshold, do not report
# unless the right side file is missing
if test -n "$size_delta_threshold" -a "$new_file_exists" = yes; then
	abs_size_difference="$size_difference"
	if test "$size_difference" -lt 0; then
		abs_size_difference=$(expr 0 - "$size_difference")
	fi 
	if test "$abs_size_difference" -le "$size_delta_threshold"; then
		exit 0
	fi
fi

files_identical="false"
if test "$new_file_exists" = yes -a "$size_difference" -eq 0; then
	if /usr/bin/cmp --silent "$orig_file" "$new_file"; then
		files_identical="true"
	fi
fi

# in mode "different", we skip the identical files to produce more concise output
if test "$mode" = "different" -a "$files_identical" = "true"; then
	exit 0
fi

# missing files are always reported regardless of size
if test "$new_file_exists" = no; then
	new_file_size="MISSING"
fi


if test "$mode" = "different" -o "$mode" = "missing"; then
	printf "$rel_file\t$orig_file_size\t$new_file_size\t$size_difference\n"
elif test "$mode" = "missing_swapped"; then
	# missing_swapped is a mode where we only want to find missing files *and* the original and new dirs are swapped
	# this means what is missing in original dir is added in new dir so the size should be reported as positive
	size_difference=$(expr 0 - "$size_difference")
	# and "orig" and "new" columns are swapped:
	printf "$rel_file\t$new_file_size\t$orig_file_size\t$size_difference\n"
else
	printf "$rel_file\t$orig_file_size\t$new_file_size\t$size_difference\t$files_identical\n"
fi

exit 0
