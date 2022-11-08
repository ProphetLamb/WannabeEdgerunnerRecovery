# Wannabe Edgerunner - Humanity Recovery

Extends the [Wannabe Edgerunner](https://www.nexusmods.com/cyberpunk2077/mods/5646) mod, to recover humanity over time.

Adds a setting specifiying the humanity recovery rate per day.
![Showcase: Settings](https://user-images.githubusercontent.com/19748542/200698305-f62bf78b-7ed4-42e4-816c-546dff08e8b8.png)

Over time, humanity penalties inflicted due to murder slowly regenerates.

![Showcase: Humanity](https://user-images.githubusercontent.com/19748542/200698707-8de548ec-3c52-48be-8ac0-5c7eb0e22ea6.png)

## Implementation details

Edgerunner lore states, that "laying off chrome" prevents Cyberpychosis. In the context of CP2077, this system interprets "laying off chrome" as emptying Cyberwear slots.

Humanity recovery rate is calculated as

$a*(\frac{c_{empty}}{c_{filled}})*t^{-1}$ where $a$ is the recovery amount, $c$ is the player Cyberware, and $t$ is the conversion from a day in-game to real time (1d in-game equals 3h time by default).

### TODO
- [ ] Fix bug where regeneration occurs on the game start screen, after load, before session start.
- [ ] Prevent humanity regeneration during combat.
- [ ] Add ru-ru local
- [ ] Add cz-cz local
- [ ] Add it-it local
- [ ] Add jp-jp local
- [ ] Add pl-pl local
- [ ] Add pt-br local
- [ ] Add zh-cn local
- [ ] Add zh-tw local
- [ ] Add es-es local

## How to build

- Open .cpmodproj in WolvenKin
- MouseR on `raw`, then MouseL on "Convert from JSON"
- "Pack as REDmod" or "Install as REDmod" in toolbar
