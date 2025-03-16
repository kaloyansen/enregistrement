#!/bin/sh

MIDI_DEVICE="20:0"
OUTDIR="$HOME/$(basename "$0")"
LAST_RECORD=$OUTDIR/last.mid
mkdir $OUTDIR
STOP_NOTE=24


echo "midi recording service started on device $MIDI_DEVICE..."
echo "press any key to start recording"
echo "press note $STOP_NOTE to stop"

aseqdump -p "$MIDI_DEVICE" | while read -r line; do

    if echo "$line" | grep -q "Note on"; then

        echo "starting new recording..."
        OUTFILE="$OUTDIR/$(date +%Y%m%d%H%M%S).mid"
        arecordmidi -p "$MIDI_DEVICE" "$OUTFILE" &
        RECORD_PID=$!

        echo "recording started"

        while read -r line; do
            if echo "$line" | grep -q "Note on" && echo "$line" | grep -q "note $STOP_NOTE"; then
                echo "stopping recording"
                kill "$RECORD_PID"
		rm -f $LAST_RECORD
                echo "recording saved to $OUTFILE"
		ln -s $OUTFILE $LAST_RECORD
                break
            fi
        done

    fi
done

