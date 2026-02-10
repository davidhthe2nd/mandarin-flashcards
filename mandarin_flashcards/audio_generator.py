import json
import os
from gtts import gTTS

# Path to your exported JSON or a list of words
deck_path = 'assets/decks/hsk1_trad_esES_deck.json'
output_dir = 'assets/audio/'

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

with open(deck_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

for card in data['cards']:
    card_id = card['id']
    text = card['hanzi']
    file_path = os.path.join(output_dir, f"{card_id}.mp3")

    if not os.path.exists(file_path):
        print(f"Generating audio for: {text}")
        tts = gTTS(text=text, lang='zh-tw')  # 'zh-tw' for Traditional/Taiwan style
        tts.save(file_path)

print("Done! Copy the assets/audio folder into your Flutter project.")