#!/bin/bash

# Customise here:
NOYB="noneofyourbusiness"
SOURCE="work"
DEST="hashes"
ENC="enc"
DEC="dec"

function usage() {
	if [ "${PWD##*/}" != "$NOYB" ] ; then
		cat <<USAGE
Go into your noyb directory:

cd $NOYB
USAGE
	fi

	cat <<USAGE
  Run the commands with the following arguments:

	  ./$ENC /path/to/folder
	  ./$DEC <optional name> (default: 16 random characters)
USAGE
  }

function gitignore() {
  if [ "${PWD##*/}" == "$NOYB" ] ; then
	  echo "" > .gitignore
	  echo $SOURCE >> .gitignore
	  echo $ENC >> .gitignore
	  echo $DEC >> .gitignore
  fi
}

if [ "${PWD##*/}" == "$NOYB" ] ; then
	echo "Welcome."
else
	# Assume from-the-web install with cURL
	if [ -d "$NOYB" ] ; then
		echo "You seem good to go: 'cd $NOYB' and start cracking."
	else
		# TODO github username
		git clone git@github.com:opyate/$NOYB.git
		cd $NOYB
		ln -s noyb.sh $ENC
		ln -s noyb.sh $DEC
		gitignore
		cat <<DOC
		Setup complete. We're decrypting from '$SOURCE' and encrypting to '$DEST'.
DOC
		usage
		exit 0
	fi
fi

BASE=$(basename $0)

echo "Executing $BASE..."

if [ "$BASE" == "$ENC" ] ; then
	if [ $# -gt 0 ] ; then
		DECRYPTED=$1
		if [ $# -eq 2 ] ; then
			ENCRYPTED=$2
			echo "Encrypting $DECRYPTED to custom destination: $DEST/$ENCRYPTED"
		else
			ENCRYPTED=$(openssl rand -hex 16 | tr -d '\r\n')
		fi

		if [ -d $DEST ] ; then
			echo "Found existing destination directory: $DEST"
		else
			mkdir -p $DEST
			echo "Created destination directory: $DEST"
		fi
		tar -czf - $DECRYPTED | openssl aes-256-cbc -out $DEST/$ENCRYPTED
		echo "Done."
		exit 0
	else
		usage
		exit 1
	fi
elif [ "$BASE" == "$DEC" ] ; then
	if [ $# -gt 0 ] ; then
		ENCRYPTED=$1
		if [ -d "$DEST" ] ; then
			echo "Decrypting $ENCRYPTED from source directory: $DEST"
			INTER=$(mktemp -t noyb)
			openssl aes-256-cbc -d -in $DEST/$ENCRYPTED -out $INTER
			mkdir -p $SOURCE/$ENCRYPTED
			tar -xzf $INTER -C $SOURCE/$ENCRYPTED
			echo "Done."
			exit 0
		else
			mkdir -p $DEST
			echo "Nothing to decrypt in $DEST... Exiting."
			exit 2
		fi
	else
		usage
		exit 1
	fi
else
	echo "Unknown command. Please try and set up again."
	exit 3
fi

