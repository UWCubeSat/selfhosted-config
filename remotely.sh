#!/bin/bash

# This script originally authored by Mark Polyakov in 2020
# I release this script to the public domain. I'd appreciate it if you left this
# message here, though.

# TODO: cancel the whole script when a remotely command fails.

function remotely_no_escape {
    ssh -S /tmp/%p-$$.sock $REMOTELY_SSH_OPTIONS "$REMOTELY_HOST" "$@"
}

function remotely {
    echo "REMOTELY: $*"
    # SSH passes its arguments to a shell, so we need to handle splitting stuff carefully. SSH takes
    # each command argument, joins them with spaces, then sends that to the remote shell. We want an
    # extra layer of quoting around each argument.
    local ssh_command=
    for arg in "$@"
    do
	arg=${arg//\\/\\\\}
	arg=${arg//\"/\\\"}
	arg=${arg//\`/\\\`}
	arg=${arg//\$/\\\$}
	ssh_command+=" \"$arg\""
    done
    remotely_no_escape "$ssh_command"
}

# args: source, destination, extra rsync args
function ez_rsync_up {
    (( $# >= 2 )) || error_out 'usage: ez_rsync_up local_path remote_path extra_opts'
    local local_path=$1
    local remote_path=$2
    shift 2
    # CUSTOMIZE: Rsync upload default options
    rsync -Rrtp --info=progress2 "$@" "$local_path" "$REMOTELY_HOST:$remote_path"
}

# args: rsync args. This function exists only for customization
function ez_rsync_down {
    # CUSTOMIZE: Rsync download default options
    rsync -rtpL --info=progress2 "$@"
}

function upload {
    env_req LDIR
    (( $# >= 1 )) || error_out 'usage: upload --extra-rsync-option /etc/path'
    echo "UPLOAD: $*"
    local local_path=$1
    shift
    ez_rsync_up "$LDIR/$local_path" / "$@"
}

# arg 1: source
# arg 2: dest
# arg 3+: rsync opts
function backup_to {
    env_req NEW_BACKUP_DIR
    (( $# >= 2 )) || error_out 'usage: backup_to src dest'
    local backup_src backup_dest_rel backup_dest_abs

    backup_src=$1
    backup_dest_rel=${2#/}
    backup_dest_abs="$NEW_BACKUP_DIR/$backup_dest_rel"
    shift 2
    mkdir -p "$(dirname "$backup_dest")"

    echo "BACKUP: $backup_src into $backup_dest_abs"

    if [[ -n "$LAST_BACKUP_DIR" ]]
    then
	# TODO: will this link dest usage work for files, or only directories?
	ez_rsync_down --link-dest="$LAST_BACKUP_DIR/$backup_dest_rel" "$@" "$REMOTELY_HOST:$backup_src" "$backup_dest_abs"
    else
	ez_rsync_down "$@" "$REMOTELY_HOST:$backup_src" "$backup_dest_abs"
    fi
}

# arg 1: src
# destination inferred, files/
function backup {
    local src=$1
    shift
    [[ $src == /* ]] || error_out "Backup path must be absolute! (infringer: $src)"
    backup_to "$src" "files/" -R "$@"
}

function error_out {
    echo "$*"
    exit 1
}

function env_req {
    [[ -n $(printenv "$1") ]] || error_out "Missing required environment variable $1"
}

function ssh_connect {
    # TODO: support custom port and/or SSH config file
    env_req REMOTELY_HOST
    echo "Establishing SSH connection to $REMOTELY_HOST"
    ssh -oControlMaster=yes -oControlPersist=${REMOTELY_CONNECTION_TIMEOUT:-200} -oControlPath=/tmp/%p-$$.sock \
	$REMOTELY_SSH_OPTIONS "$REMOTELY_HOST" exit
    export RSYNC_RSH="ssh -S /tmp/%p-$$.sock $REMOTELY_SSH_OPTIONS"
}

function process_m4_templates {
    echo 'Processing M4 templates...'
    export LDIR
    LDIR=${LDIR:-$(dirname "${BASH_SOURCE[0]}")/files}
    LDIR=${LDIR%/}
    LDIR="${LDIR}/."
    trap "find '$LDIR' -name '*.m4' -print0 | sed -z 's/.m4$//' | xargs -0 rm -f" EXIT
    find "$LDIR" -name '*~' -o -name '*#*' -delete
    # use xargs instead of -exec so that errors are fatal
    find "$LDIR" -name '*.m4' -print0 | xargs -0 -L1 --no-run-if-empty -- bash -c 'm4 -P "$0" "$1" > "${1%.m4}"' "$PWD/include.m4"
}

function prepare_backup_dir {
    env_req BACKUP_DIR
    export LAST_BACKUP_DIR NEW_BACKUP_DIR
    (( $# == 1 )) || error_out "usage: prepare_backup_dir backup_name"

    local specific_backup_dir="${BACKUP_DIR%/}/$1"
    mkdir -p "$specific_backup_dir"

    LAST_BACKUP_DIR=$(find "$specific_backup_dir" -maxdepth 1 -name '*-*-*' -type d | sort | tail -n 1)
    NEW_BACKUP_DIR="$specific_backup_dir/$(date -Iseconds)"
    echo "Backing up into $NEW_BACKUP_DIR"
    if [[ -n $LAST_BACKUP_DIR ]]
    then
	echo "(Using $LAST_BACKUP_DIR to accelerate)"
    fi
    mkdir "$NEW_BACKUP_DIR"
}

function remotely_go {
    # bail out if we're already in a remotely main
    if [[ -n $remotely_go_running ]]
    then
	    return
    fi

    set -e
    remotely_go_running=true

    # TODO: setting files/ to a backup dir for restoring?
    process_m4_templates
    ssh_connect
}

function remotely_backup {
    [[ -z $remotely_backup_running ]] || return
    (( $# == 1 )) || error_out 'usage: remotely_backup identifier'

    set -e
    remotely_backup_running=true

    prepare_backup_dir "$1"
    ssh_connect
}
