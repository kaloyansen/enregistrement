#!/bin/sh

MIDI_DEVICE=$(aconnect -l | grep "Roland Digital Piano" | grep client | awk '{print $2}')
MIDI_DEVICE="${MIDI_DEVICE}0"
OUTDIR="$HOME/$(basename "$0")"
OUTDIR=$HOME/enregistrement
LAST_RECORD=$OUTDIR/last.mid
mkdir -p $OUTDIR
STOP_NOTE=24
MUSIC=`awk 'BEGIN { print 2^(1/12) }'`
FREQ=1740


echo midi recording service start on device $MIDI_DEVICE...
# aseqdump -p "$MIDI_DEVICE" | while read -r line; do
stdbuf -oL aseqdump -p "$MIDI_DEVICE" | grep --line-buffered "Note on" | while read -r line; do

    if echo "$line" | grep -q "Note on"; then

        now=$(date +%Y%m%d%H%M%S)
        echo -n $now starting a new recording...
        OUTFILE="$OUTDIR/$now.mid"
        arecordmidi -p "$MIDI_DEVICE" "$OUTFILE" &
        RECORD_PID=$!
        echo ok
	echo press note $STOP_NOTE to stop recording

        while read -r line; do

            sleep 0.03
            if echo "$line" | grep -q "Note on" && echo "$line" | grep -q "note $STOP_NOTE"; then
                echo -n got signal ...
                kill $RECORD_PID
		rm -f $LAST_RECORD
                echo recording saved to $OUTFILE
		ln -s $OUTFILE $LAST_RECORD
                echo -n alert ...
		for i in $(seq 8); do

                    pitch=$((RANDOM % 13 - 6))
		    FREQ=$(awk -v f=$FREQ -v r="$MUSIC" -v s=$pitch 'BEGIN { printf "%.0f", f * (r ^ s) }')
                    beep -f $FREQ -l 220
		done
                echo standby
                break
            fi
        done
    fi
done
echo midi recording service stop


