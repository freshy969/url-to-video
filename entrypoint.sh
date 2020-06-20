#!/bin/bash

main() {
    log_i "Starting pulseaudio server"
    launch_pulseaudio
    log_i "Starting xvfb virtual display frame buffer."
    launch_xvfb
    node main.js
}

launch_xvfb() {
    local xvfbLockFilePath="/tmp/.X1-lock"
    if [ -f "${xvfbLockFilePath}" ]
    then
        log_i "Removing xvfb lock file '${xvfbLockFilePath}'..."
        if ! rm -v "${xvfbLockFilePath}"
        then
            log_e "Failed to remove xvfb lock file"
            exit 1
        fi
    fi

    # Set defaults if the user did not specify envs.
    export DISPLAY=${XVFB_DISPLAY:-:1}
    local screen=${XVFB_SCREEN:-0}
    local resolution=${XVFB_RESOLUTION:-1280x720x24}
    local timeout=${XVFB_TIMEOUT:-5}

    # Start and wait for either Xvfb to be fully up or we hit the timeout.
    Xvfb "${DISPLAY}" -screen "${screen}" "${resolution}" &
    local loopCount=0
    until xdpyinfo -display "${DISPLAY}" > /dev/null 2>&1
    do
        loopCount=$((loopCount+1))
        sleep 1
        if [ "${loopCount}" -gt "${timeout}" ]
        then
            log_e "xvfb failed to start"
            exit 1
        fi
    done
}

launch_pulseaudio(){
    pulseaudio -D --exit-idle-time=-1 &
}


log_i() {
    log "[INFO] ${@}"
}


log_e() {
    log "[ERROR] ${@}"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${@}"
}

main

exit