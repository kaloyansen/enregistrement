#!/usr/bin/env python

import os
import mido
from mingus.midi import fluidsynth
# import fluidsynth
import subprocess
from pydub import AudioSegment
import argparse

# from pydub.utils import which

# AudioSegment.converter = which("ffmpeg")




def change_midi_instrument(midi_file, output_midi, program_number=0):
    """Change the instrument (program number) in a MIDI file."""
    mid = mido.MidiFile(midi_file)
    
    for track in mid.tracks:
        for msg in track:
            if msg.type == 'program_change':
                msg.program = program_number  # Change instrument

    mid.save(output_midi)

def midi_to_mp3(midi_file, soundfont, mp3_file, title = "unknown", artist = "unknown", genre = "unknown"):
    """Convert MIDI to MP3 using FluidSynth and add metadata."""
    wav_file = "temp.wav"
    subprocess.run(["fluidsynth", "-ni", soundfont, midi_file, "-F", wav_file, "-r", "44100"], check=True)
    audio = AudioSegment.from_wav(wav_file)
    audio.export(mp3_file, format="mp3", tags={"title": title, "artist": artist, "genre": genre})
    subprocess.run(["rm", wav_file])


def increase_volume(input_mp3, output_mp3, db_increase = 5):

    audio = AudioSegment.from_file(input_mp3, format = "mp3")
    louder_audio = audio + db_increase
    louder_audio.export(output_mp3, format = "mp3")


def dump_font(font_path):

    fluidsynth.init(font_path)
    for bank in range(2):  # 128 banks

        for program in range(128):  # 128 programs per bank

            instrument_name = fluidsynth.get_instrument_name(bank, program) # f"program {program} (no name)"
            if instrument_name:

                print(f"Bank: {bank}, Program: {program}, Instrument: {instrument_name}")


def main():

    parser = argparse.ArgumentParser(description = "a command-line midi to mp3 converter written in python")
    parser.add_argument('-m', '--midinput', type=str, default = 'medi.mid', help="midi input file")
    parser.add_argument('-i', '--instrument', type = int, default = 42, help = "midi program number (default is 42)")
    parser.add_argument('-v', '--volume', type = int, default = 10, help = "mp3 volume (default is 10)")
    args = parser.parse_args()

    print(f"instrument: {args.instrument}, input: {args.midinput}")

    midinput = args.midinput
    jack = os.path.splitext(midinput)
    title = jack[0]

    modified_midi = f"{title}.mid.aux"
    mp3_out = f"{title}.mp3"
    mp3_aux = f"{title}.mp3.aux"
    soundfont = "/usr/share/soundfonts/FluidR3_GM.sf2"

    dump_font(soundfont)

    return

    change_midi_instrument(midinput, modified_midi, program_number = args.instrument)
    midi_to_mp3(modified_midi, soundfont, mp3_aux,
                title  = title,
                artist = "Kaloyan Krastev")
    increase_volume(mp3_aux, mp3_out, args.volume)

    print(f"converted {midinput} to {mp3_out} with instrument {args.instrument}.")


if __name__ == "__main__":
    main()
