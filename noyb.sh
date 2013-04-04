#!/bin/bash

# Customise here:
NOYB="noneofyourbusiness"
SOURCE="work"
DEST="hashes"
ENC="enc"
DEC="dec"

function usage() {
  cat <<USAGE
  Go into your noyb directory:

    cd $NOYB

  Then:

    ./$ENC /path/to/folder
    ./$DEC <optional name> (default: 16 random characters)
USAGE
}

function gitignore() {
  if [ "${PWD##*/}" == "$NOYB" ] ; then
    echo "" > .gitignore
    echo $DEST >> .gitignore
    echo $ENC >> .gitignore
    echo $DEC >> .gitignore
  fi
}

if [ "${PWD##*/}" == "$NOYB" ] ; then
  cat <<DOC
  Don't run this directly. Use the following commands instead:
DOC
  usage
else
  # Assume from-the-web install with cURL
  if [ -d "$NOYB" ] ; then
    echo "You seem good to go: 'cd $NOYB' and start cracking."
  else
    git clone git@github.com:opyate/$NOYB.git
    cd $NOYB
    ln -s noyb.sh $ENC
    ln -s noyb.sh $DEC
    gitignore
    cat <<DOC
  Setup complete. We're decrypting from '$SOURCE' and encrypting to '$DEST'.
DOC
    usage
  fi
fi

BASE=$(basename $0)

echo "Executing $BASE..."


# TODO everything further down still WIP

if [ "$BASE" == "up" ] ; then
  UNIQUE=$(openssl rand -hex 16 | tr -d '\r\n')
  openssl aes-256-cbc -in $DECRYPTED -out $ENCRYPTED
fi

if [ "$BASE" == "down" ] ; then
  openssl aes-256-cbc -d -in $ENCRYPTED -out $DECRYPTED
fi

