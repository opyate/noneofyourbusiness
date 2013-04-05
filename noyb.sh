#!/bin/bash

# Customise here:
NOYB="noneofyourbusiness"
SOURCE="work"
DEST="hashes"
ENC="save"
DEC="resume"
SECRET=".secret"

function usage() {
	if [ "${PWD##*/}" != "$NOYB" ] ; then
		cat <<USAGE
Go into your noyb directory:

cd $NOYB
USAGE
	fi

	cat <<USAGE
Usage:

	$ENC <optional /path/to/stuff/you/want/to/keep> (default: .) <optional key>
	$DEC <optional key> (default: 16 random characters)
USAGE
  }

function gitignore() {
  if [ "${PWD##*/}" == "$NOYB" ] ; then
	  echo "" > .gitignore
	  echo $SOURCE >> .gitignore
	  echo $SECRET >> .gitignore
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

# establish where the $NOYB checkout directory is
BASE=$(basename $0)
echo "basename $BASE"
DIRNAME=$(dirname $0)
echo "dirname $DIRNAME"
if [ "$DIRNAME" == "." ] ; then
	CHECKOUT=$DIRNAME
else
	# assume that the $ENC and $DEC symlinks were added to some $PATH, and use 'readlink'
	CHECKOUT=$(dirname $(readlink $0))
fi

echo "Detected checkout to be at $CHECKOUT"

echo "Executing $BASE..."

if [ "$BASE" == "$ENC" ] ; then
	if [ $# -gt 0 ] ; then
		DECRYPTED=$1
		if [ "$DECRYPTED" == "." ] ; then
			DECRYPTED=$(pwd)
		fi
	else
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
	if [ -f $SECRET ] ; then
		INTER=$(mktemp -d -t nyob)/intermediary.tgz
		tar -czf $INTER -C $DECRYPTED .
		cat $SECRET | openssl aes-256-cbc -out $DEST/$ENCRYPTED -in $INTER -kfile /dev/stdin
		rm -rf $INTER
	else
		tar -czf - -C $DECRYPTED . | openssl aes-256-cbc -out $DEST/$ENCRYPTED
	fi
	git add $DEST/$ENCRYPTED
	git commit -m "$DEST/$ENCRYPTED"
	git push origin master
	echo "Done: $ENCRYPTED"
	exit 0
elif [ "$BASE" == "$DEC" ] ; then
	if [ $# -gt 0 ] ; then
		ENCRYPTED=$1
		cd $CHECKOUT
		echo "Now working in $CHECKOUT"
		if [ -d "$DEST" ] ; then
			echo "Decrypting $ENCRYPTED from source directory: $DEST"
			INTER=$(mktemp -t noyb)
			if [ -f $SECRET ] ; then
				cat $SECRET | openssl aes-256-cbc -d -in $DEST/$ENCRYPTED -out $INTER -kfile /dev/stdin
			else
				openssl aes-256-cbc -d -in $DEST/$ENCRYPTED -out $INTER
			fi
			mkdir -p $SOURCE/$ENCRYPTED
			tar -xzf $INTER -C $SOURCE/$ENCRYPTED
			rm $INTER
			echo -e "Done. Your stuff is at \n$CHECKOUT/$SOURCE/$ENCRYPTED"
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
elif [ "$BASE" == "sh" ] ; then
	# from-the-web install with cURL
	if [ -d "$NOYB" ] ; then
		echo "You seem good to go: 'cd $NOYB' and start cracking."
	else
		# TODO github username
		git clone git@github.com:opyate/$NOYB.git
		cd $NOYB
		rm -rf $DEST
		mkdir -p ~/bin
		ln -s $(pwd)/noyb.sh ~/bin/$ENC
		ln -s $(pwd)/noyb.sh ~/bin/$DEC
		gitignore
		append_credits
		rm -rf .git
		cat <<DOC
 _   _  ______     ______  
 | \ | |/ __ \ \   / /  _ \ 
 |  \| | |  | \ \_/ /| |_) |
 | . \` | |  | |\   / |  _ < 
 | |\  | |__| | | |  | |_) |
 |_| \_|\____/  |_|  |____/ 

Setup complete!

You now need to do the following 3 things:

	- ./noyb.sh was symlinked to ~/bin/$ENC and ~/bin/$DEC, so add ~/bin to your PATH if you haven't already.
	- Run this command:
	
cd $NOYB && \\
git init && \\
git add . && \\
git commit -m "fresh installation of git@github.com:opyate/$NOYB.git" && \\
git remote add origin git@github.com:$(whoami)/noneofyourbusiness.git && \\
git push origin master

	- (optional) put a passphrase in $(pwd)/$SECRET

Now whenever you're in the middle of something, need to save it, and don't have time to faff about with keeping a copy safe somewhere...

	- noyb.sh will $ENC to   '$(pwd)/$DEST'.
	- noyb.sh will $DEC from '$(pwd)/$SOURCE'

DOC
		usage
		exit 0
	fi
else
	echo "I'm confused. You're neither running $ENC, nor $DEC, nor installing me."
	exit 3
fi

