#!/bin/sh

MIDI_DEVICE=$(aconnect -l | grep "Roland Digital Piano" | grep client | awk '{print $2}')
MIDI_DEVICE="${MIDI_DEVICE}0"
OUTDIR="$HOME/$(basename "$0")"
OUTDIR=$HOME/enregistrement
LAST_RECORD=$OUTDIR/last.mid
mkdir -p $OUTDIR
STOP_NOTE=24

echo midi recording service started on device $MIDI_DEVICE...
aseqdump -p "$MIDI_DEVICE" | while read -r line; do

    if echo "$line" | grep -q "Note on"; then

        echo -n starting a new recording...
        OUTFILE="$OUTDIR/$(date +%Y%m%d%H%M%S).mid"
        arecordmidi -p "$MIDI_DEVICE" "$OUTFILE" &
        RECORD_PID=$!
        echo ok
	echo press note $STOP_NOTE to stop recording

        while read -r line; do

            if echo "$line" | grep -q "Note on" && echo "$line" | grep -q "note $STOP_NOTE"; then
                echo -n stopping recording ...
                kill $RECORD_PID
		rm -f $LAST_RECORD
                echo recording saved to $OUTFILE
		ln -s $OUTFILE $LAST_RECORD
                echo standby
		beep -f 1760 -l 500
                break
            fi
        done
    fi
done

