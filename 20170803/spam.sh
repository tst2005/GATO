#!/bin/bash

BASE_ARC=/var/lib/sympa/arc

WD=/root/bayes
BASE_HAM=$WD/ham
BASE_SPAM=$WD/spam
WHITELIST=$WD/whitelist
BLACKLIST=$WD/blacklist


# Get the headers of a message
headers () {
	awk '/^\s*$/ {exit 0} {print $0}' $*
}

# Get a single header
header () {
	HEADER=$1
	shift
	if [ "$#" -eq 0 ] || [ -f "$1" ]; then
		HEADERS="`headers $1`"
	else
		HEADERS="$*"
	fi

	echo "$HEADERS" | awk "
		/^\w/ { if (parsing==\"Y\") exit 0 }
		/^$HEADER:/ { parsing=\"Y\" }
		{ if (parsing==\"Y\") print \$0 }
	" \
		| sed 's/^\s+/ /' \
		| tr -d '\n' \
		| sed -e "s/^$HEADER: //" \
		| mailutils 2047 --decode --charset=utf-8
}

if [ -z "$LIST" ]; then
	CHOICES="`ls $BASE_ARC | nl`"
	echo "$CHOICES" | column
	echo "Choose a list where to learn from"
	while true
	do
		read -p "[1-$(echo "$CHOICES" | wc -l)] " c
		if [ "$c" = "l" ]; then
			source ./last
			break
		fi
		LIST="`echo "$CHOICES" | grep "^\s*$c\s" | awk '{ print $2 }'`"
		[ -z "$LIST" ] || break
		echo "Invalid choice"
	done
fi

LIST_ARC=$BASE_ARC/$LIST

if [ -z "$MONTH" ]; then
	echo "Looking in \`$LIST_ARC'"

	CHOICES="`ls $LIST_ARC | nl`"
	echo "$CHOICES" | column
	echo "Choose a month where to learn from"
	while true
	do
		read -p "[1-$(echo "$CHOICES" | wc -l)] " c
		MONTH="`echo "$CHOICES" | grep "^\s*$c\s" | awk '{ print $2 }'`"
		[ -z "$MONTH" ] || break
		echo "Invalid choice"
	done
fi

echo "LIST=$LIST" > last
echo "MONTH=$MONTH" >> last

MONTH_ARC=$LIST_ARC/$MONTH/arctxt
HAM_OUT=$BASE_HAM/$LIST/$MONTH
SPAM_OUT=$BASE_SPAM/$LIST/$MONTH

mkdir -p $HAM_OUT
mkdir -p $SPAM_OUT

C_SPAM=0
C_HAM=0
C_SKIP=0
C_IGNORE=0

stats () {
	echo "Marked as SPAM:	$C_SPAM"
	echo "Marked as HAM:	$C_HAM"
	echo "Ignored:	$C_IGNORE"
	echo "Skipped:	$C_SKIP"
}

echo "Looking in \`$MONTH_ARC'"
ENTRIES="`ls $MONTH_ARC | grep '^[0-9]*$' | sort -n`"
NUM_ENTRIES="`echo "$ENTRIES" | wc -l`"
echo "$NUM_ENTRIES entries"

for ENTRY in $ENTRIES; do
	FILE=$MONTH_ARC/$ENTRY
	HAM=$HAM_OUT/$ENTRY
	SPAM=$SPAM_OUT/$ENTRY
	
	echo -n "Entry $ENTRY…"

	if [ -f "$HAM" -o -f "$SPAM" ]; then
		[ -f "$HAM" ] && TYPE=HAM
		[ -f "$SPAM" ] && TYPE=SPAM
		echo " already sorted as $TYPE, skip"
		C_SKIP=$((C_SKIP+1))
		continue
	fi

	HEADERS="`headers $FILE`"
	H_From="`header "From" "$HEADERS"`"

	L=""
	FROM_MAIL="`echo $H_From | sed 's/.*<\([^<>]*@[^<>]*\)>.*/\1/'`"

	if echo $H_From | grep -qif $BLACKLIST; then
		echo -n " \`$FROM_MAIL' in blacklist! "
		L="S"
	elif echo $H_From | grep -qif $WHITELIST; then
		echo -n " \`$FROM_MAIL' in whitelist! "
		L="H"
	fi

	if [ -z "$L" ]; then
		H_To="`header "To" "$HEADERS"`"
		H_Subject="`header "Subject" "$HEADERS"`"

		echo " to sort! [S]pam ([B]lacklist), [H]am ([W]hitelist), [I]gnore, [V]iew or [Q]uit"
		echo
		for h in From To Subject; do
			var="H_$h"
			printf "%10s | %s\n" "$h" "${!var}"
		done
		echo
	fi

	while true; do
		if [ -z "$L" ]; then
		       	read -n 1 L
			echo
		fi

		case "$L" in
			[Bb])   echo "$FROM_MAIL" >> $BLACKLIST
				echo "\`$FROM_MAIL' added to blacklist"
				;&

			[Ss])	echo "Marked as SPAM"
				cp $FILE $SPAM
				C_SPAM=$((C_SPAM+1))
				break
				;;

			[Ww])   echo "$FROM_MAIL" >> $WHITELIST
				echo "\`$FROM_MAIL' added to whitelist"
				;&

			[Hh])	echo "Marked as HAM"
				cp $FILE $HAM
				C_HAM=$((C_HAM+1))
				break
				;;

			[Ii])	echo "Ignore"
				C_IGNORE=$((C_IGNORE+1))
				break
				;;

			[Vv])	formail -b < $FILE > tmp.mbox
				mutt -f tmp.mbox
				rm tmp.mbox
				;;

			[Qq])	echo "Bye!"
				stats
				exit
				;;

			*) 	echo "Invalid option";;
		esac
		L=""
	done
done

stats
