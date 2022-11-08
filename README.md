<p align="center">
<img src="assets/icon.png" alt="Logo">

# Wannabe Edgerunner - Humanity Recovery

Mod extending the [Wannabe Edgerunner](https://www.nexusmods.com/cyberpunk2077/mods/5646) mod, to recover humanity over time.

## Implementation details

Edgerunner lore states, that "laying off chrome" prevents Cyberpychosis. In the context of CP2077, this system interprets "laying off chrome" as emptying Cyberwear slots.

Humanity recovery rate is calculated as

$a*(\frac{c_{empty}}{c_{filled}})*t^{-1}$ where $a$ is the recovery amount, $c$ is the player Cyberware, and $t$ is the conversion from a day in-game to real time (1d in-game equals 3h time by default).

### TODO
- [x] Add localizations

## How to build

- Open .cpmodproj in WolvenKin
- MouseR on `raw`, then MouseL on "Convert from JSON"
- "Pack as REDmod" or "Install as REDmod" in toolbar
