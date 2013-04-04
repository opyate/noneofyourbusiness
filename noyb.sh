#!/bin/bash

# Customise here:
NOYB="noneofyourbusiness"
SOURCE="work"
DEST="hashes"
ENC="save"
DEC="resume"

function usage() {
	if [ "${PWD##*/}" != "$NOYB" ] ; then
		cat <<USAGE
Go into your noyb directory:

cd $NOYB
USAGE
	fi

	cat <<USAGE
Run the commands with the following arguments:

	$ENC <optional /path/to/stuff/you/want/to/keep> (default: .)
	$DEC <optional name> (default: 16 random characters)
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

function append_credits() {
	cat <<CREDIT >> README.md

Credit
======

[Original](https://github.com/opyate/noneofyourbusiness) made with ♥ in London by [opyate](http://opyate.com).

:tropical_fish:
CREDIT
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
		rm -rf $DEST
		ln -s noyb.sh $ENC
		ln -s noyb.sh $DEC
		gitignore
		append_credits
		cat <<DOC
 _   _  ______     ______  
 | \ | |/ __ \ \   / /  _ \ 
 |  \| | |  | \ \_/ /| |_) |
 | . \` | |  | |\   / |  _ < 
 | |\  | |__| | | |  | |_) |
 |_| \_|\____/  |_|  |____/ 

Setup complete!

	- We're decrypting from '$SOURCE' and encrypting to '$DEST'.
	- Add $(pwd)/$ENC and $(pwd)/$DEC to your \$PATH
		-- Copy this for zsh (possibly w/o 'export'):

echo "export PATH=\\\$PATH:$(pwd)" >> ~/.zshrc
source ~/.zshrc

		-- Copy this for bash:

echo "export PATH=\\\$PATH:$(pwd)" >> ~/.bashrc
source ~/.bashrc

	- Remove the git history, and push to your own repo:

rm -rf .git
git remote add origin git@github.com:YOURNAME/YOURSAFEPLACE.git

Now whenever you're in the middle of something, need to save it, and don't have time to faff about with keeping a copy safe somewhere...
DOC
		usage
		exit 0
	fi
fi

# establish where the $NOYB checkout directory is
BASE=$(basename $0)
if [ "$(dirname $0)" == "." ] ; then
	CHECKOUT=$(dirname $0)
else
	# assume that the $ENC and $DEC symlinks were added to some $PATH, and use 'readlink'
	CHECKOUT=$(dirname $(readlink $0))
fi

echo "Detected checkout to be at $CHECKOUT"

echo "Executing $BASE..."

if [ "$BASE" == "$ENC" ] ; then
	if [ $# -gt 0 ] ; then
		DECRYPTED=$1
	else
		echo "Assume current directory? <any> for y, <Ctrl-C> for n..."
		read any
		DECRYPTED=$(pwd)
	fi
	if [ $# -eq 2 ] ; then
		ENCRYPTED=$2
	else
		ENCRYPTED=$(openssl rand -hex 16 | tr -d '\r\n')
	fi

	# got to checkout now, and do stuff
	cd $CHECKOUT
	echo "Now working in $CHECKOUT"

	if [ -d $DEST ] ; then
		STATUS="existing"
	else
		mkdir -p $DEST
		STATUS="new"
	fi
	echo "Found *$STATUS* destination directory: $(pwd)/$DEST"
	echo "Blob will be saved to $(pwd)/$DEST/$ENCRYPTED"
	tar -czf - -C $DECRYPTED . | openssl aes-256-cbc -out $DEST/$ENCRYPTED
	git add $DEST/$ENCRYPTED
	git commit -m "$DEST/$ENCRYPTED"
	git push origin master
	echo "Done."
	exit 0
elif [ "$BASE" == "$DEC" ] ; then
	if [ $# -gt 0 ] ; then
		ENCRYPTED=$1
		cd $CHECKOUT
		echo "Now working in $CHECKOUT"
		if [ -d "$DEST" ] ; then
			echo "Decrypting $ENCRYPTED from source directory: $DEST"
			INTER=$(mktemp -t noyb)
			openssl aes-256-cbc -d -in $DEST/$ENCRYPTED -out $INTER
			mkdir -p $SOURCE/$ENCRYPTED
			tar -xzf $INTER -C $SOURCE/$ENCRYPTED
			rm $INTER
			echo "Done. Your stuff is at \n$CHECKOUT/$SOURCE/$ENCRYPTED"
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

