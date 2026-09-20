<div align="center">

<img src="assets/icon/icon_adaptive_foreground_solid.png" alt="Icon" width="180"/>

# 👁️ Who Knows!

### 🕵️ Someone knows the word.

### Someone doesn't.

### Someone is lying.

**A chaotic local pass-and-play social deduction party game.**

<br/>

<a href="#-features">
  <img src="https://img.shields.io/badge/🎮-Features-FFD60A?style=for-the-badge&labelColor=0D0D0D" alt="Features"/>
</a>
<a href="#-getting-started">
  <img src="https://img.shields.io/badge/🚀-Get%20Started-4CC9F0?style=for-the-badge&labelColor=0D0D0D" alt="Get Started"/>
</a>
<a href="#-gameplay">
  <img src="https://img.shields.io/badge/🕵️-How%20It%20Works-06D6A0?style=for-the-badge&labelColor=0D0D0D" alt="How It Works"/>
</a>

<br/><br/>

![Flutter](https://img.shields.io/badge/Flutter-3.47.4-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-API%2036-3DDC84?style=flat-square&logo=android&logoColor=white)
![Web](https://img.shields.io/badge/Web-Supported-4CC9F0?style=flat-square&logo=googlechrome&logoColor=white)

<br/>

**📱 One phone. 👥 A group of friends. 🕵️ One suspicious person.**

</div>

---

## 🎮 What is Who Knows!?

**Who Knows!** is a local social deduction party game built with Flutter.

Everyone gathers around **one phone**.

The app secretly gives players their information.

Then the phone goes down.

The humans take over.

Players give clues, argue, accuse their friends of crimes they probably didn't commit, and eventually agree on **one person** to eliminate.

The app then reveals the truth.

Simple.

Until someone starts acting suspicious. 👀

---

## 🧠 How It Works

```text
        👥 PLAYERS
             │
             ▼
      ⚙️ GAME SETUP
             │
             ▼
      📱 PASS THE PHONE
             │
             ▼
       🔐 SECRET REVEAL
             │
             ▼
       🗣️ GIVE CLUES
             │
             ▼
        💬 DISCUSS
             │
             ▼
       🕵️ PICK SUSPECT
             │
             ▼
        🎯 REVEAL
             │
        ┌────┴────┐
        ▼         ▼
     IMPOSTER   CIVILIAN
        │         │
        ▼         ▼
      😈        💀
     CHAOS      OOPS
🔥 The Core Idea

There is no individual voting.

There is no typing clues into the phone.

There is no online lobby.

There is just:

Talk → Suspect → Decide → Reveal

Because apparently getting five friends to agree on one person is harder than building the application.

🕵️ The Imposter

Most players receive the same secret word.

The Imposter doesn't.

Example:

Category: FOOD

Civilians:
🍕 PIZZA

Imposter:
❓ ???

The Imposter has to survive the conversation without knowing exactly what everyone is talking about.

Good luck.

🌪️ Chaos Mode

Normal mode is already suspicious.

Chaos Mode asks:

"What if we made it worse?"

The game can randomly determine the number of Imposters.

Potentially:

0 Imposters
1 Imposter
2 Imposters
3 Imposters
...
Everyone

Yes.

Sometimes there may be nobody to catch.

Sometimes there may be way too many people to catch.

Humanity has invented a party game that doesn't even guarantee the existence of a criminal.

🌀 Chaos Words

Normally:

Player 1 → 🍕 Pizza
Player 2 → 🍕 Pizza
Player 3 → 🍕 Pizza
Player 4 → ❓ ???

With Chaos Words:

Player 1 → 🍕 Pizza
Player 2 → 🍔 Burger
Player 3 → 🌮 Taco
Player 4 → 🍜 Ramen

Everyone walks into the discussion thinking they're right.

Which is exactly the problem.

💡 Imposter Hint

The Imposter can optionally receive a category hint.

For example:

CATEGORY
────────────
FOOD

WORD
████████

The category is revealed.

The actual word isn't.

Just enough information to make the Imposter dangerous.

🎯 Final Guess

If enabled, catching the Imposter isn't necessarily the end.

The Imposter gets one final chance:

Guess the secret word.

Correct:

😈 IMPOSTER WINS

Wrong:

🎉 CIVILIANS WIN

You can also disable Final Guess completely.

✨ Features
👥 3–20 players
📱 Single-device pass-and-play
🕵️ Imposter gameplay
🌪️ Chaos Mode
🌀 Chaos Words
🗣️ Verbal clues
🗳️ Collective voting
💡 Optional Imposter category hint
🎯 Optional Final Guess
🗂️ Selectable word categories
🎲 Random word selection
🚫 No Easy / Medium / Hard word tiers
🌐 Flutter Web support
📱 Android support
👁️ The Identity

The game's visual identity revolves around an abstract observer.

The eye represents the central question of the game:

Who knows?

The launcher icon uses:

🟨 Yellow background
⚫ Black observer silhouette
👁️ Yellow eye ring
⚫ Black pupil

No giant text.

No neon cyberpunk explosion.

Just an eye staring at your friend while they desperately pretend they know the word.

🛠️ Built With
Technology	Purpose
🐦 Flutter	Application framework
🎯 Dart	Programming language
🤖 Android	Primary platform
🌐 Flutter Web	Web version
💾 Local state	Game state
📚 Word Database	Secret words & categories
🚀 Getting Started
Requirements

Install:

Flutter SDK
Dart SDK
Android Studio
Android SDK
Android device or emulator

Check your Flutter installation:

flutter doctor

Check connected devices:

flutter devices
📦 Install

Clone the repository:

git clone https://github.com/mhdsahil1/Who_Knows
cd who_knows

Install dependencies:

flutter pub get
📱 Run on Android

Connect an Android device with USB debugging enabled.

flutter devices

Then:

flutter run -d CPH2665

Replace CPH2665 with your device ID.

🌐 Run on Web

Chrome:

flutter run -d chrome

Edge:

flutter run -d edge
🧪 Development

Run static analysis:

flutter analyze

Run tests:

flutter test
📂 Project Structure
who_knows/
│
├── android/
├── web/
├── assets/
│   └── icon/
│       └── icon_adaptive_foreground_trans.png
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── models/
│   ├── game/
│   ├── screens/
│   ├── widgets/
│   ├── data/
│   ├── services/
│   └── constants/
│
├── test/
├── pubspec.yaml
└── README.md
🧭 Project Status
🚧 Active Development

Current baseline:

Flutter              ✅
Android              ✅
Physical device      ✅
Game playable        ✅
Web                  ✅
Word database        ✅
Pass-and-play        ✅
Chaos Mode           🚧
Chaos Words          🚧
UI redesign          🚧
Final branding       🚧
🛡️ Stable Checkpoints

Before making major changes:

git status

Then create a checkpoint:

git add .
git commit -m "chore: stable working checkpoint"
git push

The stable checkpoint should always represent a version that successfully builds and runs on the Android test device.

🗺️ Roadmap
 Basic game engine
 Player setup
 Secret role reveal
 Discussion phase
 Collective voting
 Final Guess system
 Category selection
 Physical Android testing
 Final launcher icon integration
 Android adaptive icon
 Web favicon
 Major UI/UX redesign
 Gesture-based secret reveal
 Animated countdown
 Chaos Mode refinement
 Chaos Words
 Expand word database
 Remove obsolete difficulty-tier system
 More gameplay testing
 Release build
🤝 Contributing

This is currently a personal/fun development project.

If you contribute:

Keep the game simple.
Don't break the pass-and-play experience.
Don't turn the app into a chat application.
Don't add unnecessary online dependencies.
Keep secret information private.
Keep the visual identity recognizable.
Test on Android before submitting major changes.
📜 License

License information will be added when the project's distribution model is finalized.

```
