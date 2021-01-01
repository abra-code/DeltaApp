#! /bin/bash

show_help()
{
	echo ""
	echo "CompareDirs -- compare two directories and produce report in tsv format"
	echo ""
	echo "Usage: CompareDirs.bash path/to/dir1 path/to/dir2 <mode>"
	echo ""
	echo "The \"mode\" parameter may be one of the following:"
	echo "    \"full\" or \"all\" - report all files regardless of differences - default"
	echo "    \"different\" - report only files which are different"
	echo "    \"missing\" - report only files which are added or removed"
	echo "    number - report only files with size difference above the number threshold"
	echo ""
	echo "The tab sparated values (tsv) report is printed to stdout."
	echo ""
	echo "Examples:"
	echo "./CompareDirs.bash path/to/dir1 path/to/dir2 different > different-files.tsv"
	echo "./CompareDirs.bash path/to/dir1 path/to/dir2 missing > missing-files.tsv"
	echo "./CompareDirs.bash path/to/dir1 path/to/dir2 64 > delta-above-64-bytes.tsv"
	echo ""
}

# given two paths get directory names which are different,
# starting from the end and place in:
left_dir_name=
right_dir_name=

# if the paths are the same, left_dir_name and right_dir_name will be the same and equal to
# the last path component
get_dir_names_for_path_difference()
{
	local left_dir="$1"
	local right_dir="$2"
	left_dir_name=$(basename "$left_dir")
	right_dir_name=$(basename "$right_dir")
	if test "$left_dir_name" = "$right_dir_name"; then
		local left_parent=$(dirname "$left_dir")
		local right_parent=$(dirname "$right_dir")
		if test "$left_parent" != "$right_parent"; then
			get_dir_names_for_path_difference "$left_parent" "$right_parent"
		fi
	fi
}

orig_dir=$1
new_dir=$2
# mode: "all"/"full", "different", "missing", minimum size delta integer, e.g.: "100"
mode=$3

if test -z "$1" -o -z "$2" -o "$1" = "-h" -o "$1" = "--help"; then
	show_help
	exit 0
fi

if test ! -d "$orig_dir"; then
	echo "Error: specified directory does not exist: $orig_dir"
	exit 1
fi

if test ! -d "$new_dir"; then
	echo "Error: specified directory does not exist: $new_dir"
	exit 1
fi

size_delta_threshold=""

# check if the passed param is a number.
# if yes, it means size threshold above which we should report
# implies "different" mode

if test -n "$mode" -a "$mode" -eq "$mode" 2>/dev/null; then
	size_delta_threshold="$mode"
	mode="different"
elif test -z "$mode"; then
	mode="full"
fi

#echo "mode = $mode"
#echo "size_delta_threshold = $size_delta_threshold"

get_dir_names_for_path_difference "$orig_dir" "$new_dir"

if test "$mode" = "different" -o "$mode" = "missing"; then
	printf "File Path\t$left_dir_name\t$right_dir_name\tDelta\n"
else
	printf "File Path\t$left_dir_name\t$right_dir_name\tDelta\tIdentical?\n"
fi

replay="$OMC_APP_BUNDLE_PATH/Contents/MacOS/replay"
script_dir="$OMC_APP_BUNDLE_PATH/Contents/Resources/Scripts"

# if dir is relative, let's go back to the start
cd "$start_dir"
cd "$new_dir"
# absolute path:
new_dir=$(/bin/pwd)

# if dir is relative, let's go back to the start
cd "$start_dir"
cd "$orig_dir"
# absolute path:
orig_dir=$(/bin/pwd)

export script_dir
export orig_dir
export new_dir
export mode
export size_delta_threshold

# perf of "find" executing script in child shell for each file is pretty poor
# "replay" speeds it up by 4-5 times

# /usr/bin/find -s . -type f -exec /bin/bash "$script_dir/CompareFiles.bash" "$orig_dir" "$new_dir" {} "$mode" "$size_delta_threshold" ';'
/usr/bin/find -s . -type f | /usr/bin/sed -E 's|(.+)|[execute]\t/bin/bash\t${script_dir}/CompareFiles.bash\t${orig_dir}\t${new_dir}\t\1\t${mode}\t${size_delta_threshold}|' | "$replay" --ordered-output

# second pass is on the new dir to discover the missing files in original dir, in other words: files added to new dir
cd "$new_dir"

# /usr/bin/find -s . -type f -exec /bin/bash "$script_dir/CompareFiles.bash" "$new_dir" "$orig_dir" {} "missing_swapped" "" ';'
/usr/bin/find -s . -type f | /usr/bin/sed -E 's|(.+)|[execute]\t/bin/bash\t${script_dir}/CompareFiles.bash\t${new_dir}\t${orig_dir}\t\1\tmissing_swapped\t|' | "$replay" --ordered-output
