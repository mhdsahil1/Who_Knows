<div align="center">

<img src="assets/icon/icon_adaptive_foreground_solid.png" alt="Who Knows! Icon" width="180"/>

# WHO KNOWS!

### A local social deduction party game built for real-world chaos.

<p>
  <strong>Think.</strong>
  <strong>Bluff.</strong>
  <strong>Accuse.</strong>
  <strong>Survive.</strong>
</p>

<br>

<a href="#download">
  <img src="https://img.shields.io/badge/Download-APK-000000?style=for-the-badge&logo=android&logoColor=white" alt="Download APK"/>
</a>
<a href="#features">
  <img src="https://img.shields.io/badge/Explore-Features-F5C400?style=for-the-badge" alt="Features"/>
</a>
<a href="#game-modes">
  <img src="https://img.shields.io/badge/Game-Modes-4DB6FF?style=for-the-badge" alt="Game Modes"/>
</a>

<br><br>

<img src="https://readme-typing-svg.demolab.com?font=Space+Grotesk&weight=600&size=22&pause=1200&color=F5C400&center=true&vCenter=true&width=600&lines=One+phone.+A+group+of+friends.+One+imposter.;Trust+nobody.;Can+you+find+the+imposter%3F" alt="Animated tagline"/>

</div>

---

## About

**Who Knows!** is a mobile-first local social deduction party game designed for groups playing together in the same physical space.

Everyone receives a secret word except the Imposter.

Players give verbal clues, discuss suspicious behavior, and collectively decide who they believe is the Imposter.

The catch?

There is only one phone.

Pass it around. Keep your role secret. Bluff carefully.

---

## How It Works

```text
        START
          │
          ▼
     ADD PLAYERS
          │
          ▼
      GAME MODE
          │
          ▼
   IMPOSTER SETTINGS
          │
          ▼
   WORDS & CATEGORIES
          │
          ▼
      ROLE REVEAL
          │
          ▼
      DISCUSSION
          │
          ▼
         VOTE
          │
      ┌───┴────┐
      │        │
   CORRECT   WRONG
      │        │
      ▼        ▼
    RESULT   NEXT ROUND
```

The game is designed around **pass-and-play** interaction.

Players do not submit clues through the app. The conversation happens face-to-face.

---

## Features

### Local Pass-and-Play

Designed for groups sitting together.

- No accounts
- No online matchmaking
- No complicated setup
- One device
- Up to 20 players

The phone is simply passed from player to player during the private role reveal.

---

## Game Modes

### Classic Mode

Keep playing until the Imposter is successfully identified.

```text
Role Assignment
      ↓
Discussion
      ↓
Vote
      ↓
Correct?
 ┌────┴────┐
 YES       NO
  ↓         ↓
RESULT   NEW ROUND
```

A wrong vote starts another round with a new role assignment.

### One-Shot Vote

One discussion.

One vote.

One chance.

The group gets exactly one opportunity to identify the Imposter.

```text
Role Assignment
      ↓
Discussion
      ↓
ONE VOTE
      ↓
   RESULT
```

If the selected player is an Imposter, the Civilians succeed unless the Final Guess changes the outcome.

If the selected player is a Civilian, the Imposters win immediately.

---

## Imposter System

Who Knows! supports configurable Imposter behavior.

### Imposter Count

The game can recommend an Imposter count based on the number of players while still allowing custom configuration.

### Can Imposter Start?

Choose whether the randomly selected starting player can be an Imposter.

If disabled, the starting player is selected from the Civilian players whenever possible.

### Imposters Know Each Other

When multiple Imposters are present, you can decide whether they should know the identities of their teammates.

If enabled, Imposters privately see their fellow Imposters during role reveal.

Civilians never receive this information.

---

## Chaos Mode

For groups that prefer unpredictability.

Chaos Mode can randomize the Imposter setup instead of following the standard configuration.

### Chaos Words

Players can receive different words.

This creates a more unpredictable game where players cannot automatically assume that everyone received the same secret word.

---

## Final Guess

Caught the Imposter?

Not necessarily the end.

When **Final Guess** is enabled, a caught Imposter gets one final opportunity to identify the secret word.

```text
IMPOSTER CAUGHT
       │
       ▼
   FINAL GUESS
       │
   ┌───┴────┐
 CORRECT   WRONG
    │         │
    ▼         ▼
IMPOSTERS   CIVILIANS
   WIN         WIN
```

For Associated Words, the final guess can use the associated phrase or its base word according to the game's rules.

---

## Word System

Who Knows! supports multiple word sources.

### Built-in Categories

Choose from available categories such as:

- Internet
- School
- Memes
- Channels
- Apps
- Entertainment
- And more

Categories are dynamically derived from the word database.

---

### My Words

Create your own private word collection.

Custom words are stored locally and can be enabled during game setup.

Useful for:

- Inside jokes
- Friend groups
- College life
- Local references
- Personal themes

---

### Associated Words

Associated Words dynamically attach a generic word to a player.

For example:

```text
Generic Word
     ↓
    Bike
     ↓
Selected Player
     ↓
   Sahil
     ↓
"Sahil's Bike"
```

The association is generated dynamically instead of storing every possible player-word combination.

---

## Player Setup

Who Knows! supports up to:

# 20 Players

The setup process is divided into simple steps:

```text
01  Players
 ↓
02  Game Mode
 ↓
03  Imposter Settings
 ↓
04  Words & Categories
 ↓
05  Ready
```

The goal is to keep setup quick so the group can get into the game instead of spending five minutes configuring it.

---

## Design

The interface follows a minimal visual language built around a controlled color palette:

- Black
- Off-white
- Yellow
- Sky Blue
- Green
- Controlled Red

The game uses an abstract **eye / observer** visual concept throughout the experience.

The idea is simple:

> Someone is always watching.

---

## Technology

<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.47.4-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
<img src="https://img.shields.io/badge/Dart-Flutter-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
<img src="https://img.shields.io/badge/Android-Primary-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
<img src="https://img.shields.io/badge/Web-Supported-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Web"/>

</div>

### Core Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI |
| Dart | Application logic |
| SharedPreferences | Local persistence |
| Android | Primary mobile platform |
| Web | Secondary supported platform |

---

## Project Structure

```text
who_knows/
│
├── assets/
│   ├── icon/
│   ├── images/
│   └── videos/
│
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── ...
│
├── test/
│
├── android/
├── web/
│
├── pubspec.yaml
└── README.md
```

---

## Startup Experience

The application opens with the SARCODE studio animation before transitioning into the Who Knows! game identity.

```text
┌─────────────────────┐
│                     │
│       SARCODE       │
│                     │
│  Build Beyond Ideas │
│                     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│                     │
│     WHO KNOWS!      │
│                     │
└──────────┬──────────┘
           │
           ▼
      HOME SCREEN
```

The startup sequence establishes the studio identity before entering the game.

---

## Download

### Android

Download the latest Android APK from GitHub Releases.

<div align="center">

<a href="https://github.com/mhdsahil/Who_Knows/releases">
  <img src="https://img.shields.io/badge/Download-Latest%20Android%20APK-000000?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK"/>
</a>

</div>

### Installation

1. Download the latest `.apk`.
2. Open the APK on your Android device.
3. Allow installation from the required source if Android asks.
4. Install the application.
5. Launch **Who Knows!**

The application is currently distributed independently and is not available through Google Play.

---

## Web

The web version is also supported.

<div align="center">


Sorry!!!...Not Yet 

  <img src="https://img.shields.io/badge/Play-Online-4DB6FF?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Play Online"/>
</a>

</div>

---

## Development

### Requirements

- Flutter 3.47.4 or compatible version
- Dart SDK
- Android Studio or VS Code
- Android SDK
- Chrome for Web development

### Run Locally

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git

cd who_knows

flutter pub get

flutter run
```

### Run on Chrome

```bash
flutter run -d chrome
```

### Run on Android

```bash
flutter devices

flutter run -d <device-id>
```

---

## Testing

### Static Analysis

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Build Release APK

```bash
flutter build apk --release
```

The release APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Roadmap

### Completed

- [x] Local pass-and-play gameplay
- [x] Imposter system
- [x] Multiple Imposters
- [x] Classic Mode
- [x] One-Shot Vote
- [x] Chaos Mode
- [x] Chaos Words
- [x] Final Guess
- [x] Custom My Words
- [x] Associated Words
- [x] Dynamic categories
- [x] Starting Player
- [x] Can Imposter Start
- [x] Imposters Know Each Other
- [x] Up to 20 players
- [x] Android release build
- [x] Web support
- [x] SARCODE startup branding

### Planned

- [ ] Additional game modes
- [ ] More word categories
- [ ] More customization
- [ ] Additional visual polish
- [ ] Future platform expansion

---

## Contributing

Contributions, suggestions, bug reports, and improvements are welcome.

If you find a bug or have an idea for improving the game:

1. Open an issue.
2. Describe the problem or feature clearly.
3. Include reproduction steps where applicable.
4. Submit a pull request for implementation changes.

---

## License

This project is currently distributed under the license specified in the repository.

See [`LICENSE`](LICENSE) for details.

---

<div align="center">

<img src="assets/icon/icon_adaptive_foreground_solid.png" alt="Who Knows!" width="90"/>

# WHO KNOWS!

**Think. Bluff. Accuse.**

<br>

Built by **SARCODE**

### Build Beyond Ideas.

<br>

<a href="https://github.com/mhdsahil/Who_Knows">
  <img src="https://img.shields.io/badge/GitHub-Repository-111111?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repository"/>
</a>

</div>m