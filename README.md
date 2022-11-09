<p align="center">
<img src="assets/banner.png" alt="Logo">

# Wannabe Edgerunner - Humanity Recovery

**Find me on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/6330).**

Extends the [Wannabe Edgerunner](https://www.nexusmods.com/cyberpunk2077/mods/5646) mod, to recover humanity over time.

## Features

* Adds a setting specifying the amount of humanity recovered per day, if no Cyberware is equipped. Equipped cyberware reduces the recovery-rate proportionally to the number of slots filled. So that no humanity is recovered, if all slots are filled.
* Adds a setting specifying the Cyberware load at which no humanity is recovered. Any load above degens humanity, and any load below regens humanity. The load is calculated as the number of slots filled divided by the number of slots available.

![Showcase: Settings](https://user-images.githubusercontent.com/19748542/200834546-c1a1492d-c6d6-4ea4-9d5a-044c23781f6c.png)

Over time, humanity penalties inflicted due to murder slowly regenerates.

![Showcase: Humanity](https://user-images.githubusercontent.com/19748542/200698707-8de548ec-3c52-48be-8ac0-5c7eb0e22ea6.png)

## Implementation details

Edgerunner lore states, that "laying off chrome" prevents Cyberpychosis. In the context of CP2077, this system interprets "laying off chrome" as emptying Cyberwear slots.

Humanity recovery is calculated as a linear interpolation in two parts.

- If the **Cyberware load is higher than the threshold** degens humanity proportional to the load over the threshold. Interpolates $$l \in [k,1] -> [0,-r]$$ where $l$ is the load, $k$ is the threshold (settings), and $r$ is the recovery rate (settings)

- If the **Cyberware load is higher than the threshold** regens humanity proportional to the load under the threshold Interpolates $$l \in [0,k] -> [0,r]$$ where $l$ is the load, $k$ is the threshold (settings), and $r$ is the recovery rate (settings)

This is illustrated in the diagram below.
```
  thres
-1 --|------------- 1 rate
    /\
    /    \
  /        \
  /            \
/          \ 
0------------------1 load
```

### TODO
- [ ] Fix bug where regeneration occurs on the game start screen, after load, before session start. [rn, circumvented by delay]
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
