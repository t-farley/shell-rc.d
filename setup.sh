#!/bin/sh

set -e

DEFAULT_DIR=.sh
DEFAULT_RCFILE=.zshrc

read -r -p "Enter your shell setup directory ($DEFAULT_DIR): " DIR

if [ "$DIR" == "" ]; then
    DIR=$DEFAULT_DIR
fi

# Check if $DIR already exists
if [ -d "$HOME/$DIR" ]; then
    echo "Directory ~/$DIR already exists!"
    read -r -p "Continue and overwrite existing files? (y/N): " AT_OWN_RISK

    # Convert to uppercase
    AT_OWN_RISK=$(echo "$AT_OWN_RISK" | tr '[:lower:]' '[:upper:]')

    if [ "$AT_OWN_RISK" != "Y" ]; then
        echo "Cancelling setup!"
        exit 0
    fi

    echo "Continuing at your own risk!"
fi

read -r -p "Enter your rc file name ($DEFAULT_RCFILE): " RCFILE

if [ "$RCFILE" == "" ]; then
    RCFILE=$DEFAULT_RCFILE
fi

echo "Creating $HOME/$DIR and adding files"
mkdir -p $HOME/$DIR
cp -R src/all/* $HOME/$DIR

if [ "$(uname)" == "Darwin" ]; then
    read -r -p "Perform macOS specific setup? (y/N): " SETUP_MAC

    SETUP_MAC=$(echo "$SETUP_MAC" | tr '[:lower:]' '[:upper:]')

    if [ "$SETUP_MAC" == "Y" ]; then
        echo "Copying macOS specific files"
        cp -R src/macOS/* $HOME/$DIR
    fi
fi

SHELL=$(ps -p "$PPID" -o comm=)

if [ "$SHELL" == "-zsh" ]; then
    read -r -p "Perform zsh specific setup? (y/N): " SETUP_ZSH

    SETUP_ZSH=$(echo "$SETUP_ZSH" | tr '[:lower:]' '[:upper:]')

    if [ "$SETUP_ZSH" == "Y" ]; then
        echo "Copying zsh specific files"
        cp -R src/zsh/* $HOME/$DIR
    fi
fi

if [ -f "$HOME/$RCFILE" ]; then
    read -r -p "Copy contents of existing $RCFILE to rc.d? (y/N): " COPY_RCFILE

    COPY_RCFILE=$(echo "$COPY_RCFILE" | tr '[:lower:]' '[:upper:]')

    if [ "$COPY_RCFILE" == "Y" ]; then
        echo "Copying $RCFILE to $HOME/$DIR/rc.d"
        cp $HOME/$RCFILE $HOME/$DIR/rc.d/99-original
    else
        read -r -p "Backup contents of existing $RCFILE? (Y/n): " BACKUP_RCFILE
        BACKUP_RCFILE=$(echo "$BACKUP_RCFILE" | tr '[:lower:]' '[:upper:]')

        if [ "$BACKUP_RCFILE" == "Y" ]; then
            BACKUP_APPEND=_backup_$(date +%F)
            BACKUP_FILENAME="$RCFILE$BACKUP_APPEND"
            echo "Backing up $RCFILE to $BACKUP_FILENAME"
            cp $HOME/$RCFILE $HOME/$BACKUP_FILENAME
        fi
    fi
fi

exit 0

echo "source $DIR/rc" > $HOME/$RCFILE