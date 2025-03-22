#!/bin/sh

MIDI_ID="0582:01f1"
APP_NAME=enregistrement
MIDI_DIRECTORY=$HOME/$APP_NAME
LAST_RECORD=$MIDI_DIRECTORY/last.mid
STOP_NOTE=24
MUSIC=`awk 'BEGIN { print 2^(1/12) }'`
FREQ=1740

device_is_connected() {

    lsusb | grep -q "$MIDI_ID"
    return $?
}

get_midi_device() {

    export MIDI_DEVICE=$(aseqdump -l | grep "Piano" | awk '{print $1}')
}

save_midi() {

    echo -n killing $1
    kill $1 2>/dev/null && echo $1 is dead || echo cannot kill $1
    rm -f $LAST_RECORD
    echo recording saved to $2
    ln -s $2 $LAST_RECORD
    echo -n alert ...
    for i in $(seq 8); do

	pitch=$((RANDOM % 13 - 6))
	FREQ=$(awk -v f=$FREQ -v r="$MUSIC" -v s=$pitch 'BEGIN { printf "%.0f", f * (r ^ s) }')
	beep -f $FREQ -l 220&
    done
}

dump_sequence() {

    get_midi_device
    echo enter dump sequence loop on $MIDI_DEVICE
    stdbuf -oL aseqdump -p "$MIDI_DEVICE" | grep --line-buffered "Note on" | while read -r line; do

        if echo "$line" | grep -q "Note on"; then

	    now=$(date +%Y%m%d%H%M%S)
	    echo -n $now starting a new recording...
	    OUTFILE="$MIDI_DIRECTORY/$now.mid"
	    arecordmidi -p "$MIDI_DEVICE" "$OUTFILE" &
	    RECORD_PID=$!
	    echo record pid $RECORD_PID
	    echo press note $STOP_NOTE to stop recording
	    while read -r line; do

		if echo "$line" | grep -q "Note on" && echo "$line" | grep -q "note $STOP_NOTE"; then

		    echo -n got stop signal ...
		    save_midi $RECORD_PID $OUTFILE 
		    echo standby
		    break
		fi
	    done
	fi
    done
}


mkdir -p $MIDI_DIRECTORY
get_midi_device
echo midi recording service start on device $MIDI_DEVICE ...
device_is_connected
echo device is connected $?

while true; do

    DUMPID=${DUMPID:-0}
    if ! device_is_connected; then

	if [ "$DUMPID" -gt 0 ]; then

	    echo -n killing $DUMPID ...
	    kill $DUMPID 2>/dev/null && echo $DUMPID is dead || echo cannot kill $DUMPID 
	    DUMPID=0
	fi
    else

	if [ "$DUMPID" -eq 0 ]; then

            dump_sequence&
	    DUMPID=$!
	    echo started dumping $MIDI_ID with pid $DUMPID
	fi
    fi
    sleep 3
done


