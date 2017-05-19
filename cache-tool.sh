#!/bin/sh

# ==== Functions

function usage() {
    echo ""
    echo "Usage: $0 action [name:dir] [name:dir] ..."
    echo ""
    echo "Parameters:"
    echo "    action:      Either 'collect' or 'extract'"
    echo "    name:        A name given to the cache object"
    echo "    directory:   The directory that's be cached under the given name"
    echo ""
    echo "Example:"
    echo "    $0 collect composer:~/.composer"
    echo ""
    exit 1
}

function collectCache() {
    IFS=:
    set $1
    eval dir=$2
    if [ ! -d $dir ]; then
        echo "  ! Directory $2 does not exist, skipping..."
        return
    fi
    echo "  - Collecting $2 into .cache/$1...";
    cp -R $dir .cache/$1
}

function extractCache() {
    IFS=:
    set $1
    eval dir=$2
    if [ ! -d .cache/$1 ]; then
        echo "  ! Cache directory .cache/$1 does not exist, skipping..."
        return
    fi
    echo "  - Extracting .cache/$1 into $2...";
    mkdir -p $dir && rm -rf $dir
    cp -R .cache/$1 $dir
}

# ==== Start of the program

if [ $# -lt 2 ]; then
    usage;
fi

if [[ "$1" != "collect" && "$1" != "extract" ]]; then
    usage;
fi

ACTION=$1; shift;

if [[ "$ACTION" == "collect" ]]; then
    echo "Collecting the cache..."
    echo "  - Creating the .cache directory..."
    mkdir -p .cache;
    for cache in "$@"; do
        collectCache "$cache"
    done
    echo "Done!"
else
    echo "Extracting the cache..."
    mkdir -p .cache;
    for cache in "$@"; do
        extractCache "$cache"
    done
    echo "  - Removing the .cache directory..."
    rm -rf .cache
    echo "Done!"
fi
