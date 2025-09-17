# Oficiální čeština pro **Heroes of Might and Magic III: Complete**

Tento balíček obsahuje **oficiální český překlad (CD Projekt)** pro Heroes of Might and Magic III: Complete.

- Funguje na **jakoukoli jazykovou verzi „Complete“** – GOG / CD / Ubisoft Connect / Epic  
- Přeloženo: **rozhraní, kampaně, mapy a manuál**
- **Součástí je čeština pro HD Launcher 5.5 R74** nebo novější
- **Instalátor podporuje Windows XP a novější** (32/64-bit)

 
> **Před instalací hru ukončete.**  
> Instalací potvrzujete, že vlastníte **legální kopii** hry Heroes of Might and Magic III: Complete.

---

## Stažení a instalace (doporučeno)

1. Stáhněte **`H3_CZ_Patcher.exe`** z [Releases](../../releases).  
2. Spusťte instalátor. Ten **automaticky detekuje** cestu k instalaci (GOG / Ubisoft / Epic / původní NWC klíče).  
   Cestu lze ručně změnit – vybírá se **kořen hry**.
3. Klikněte **Instalovat** a vyčkejte na dokončení.  
4. Hotovo – spusťte hru.

### Co instalátor dělá

- Importuje připravené soubory do LOD archivů v `…\data` (`H3bitmap.lod`, `H3sprite.lod`, `H3ab_bmp.lod`, `H3ab_spr.lod`).  
- **Nahradí složku `Maps`** obsahem z balíčku.  
- Zkopíruje **PDF manuály** a **README.txt** do kořene hry.  
- Nainstaluje české texty pro **HD Launcher 5.5 R74** nebo novější (pokud je přítomen).  
- Po dokončení instalace **spustí hru** nebo **HD Launcher**.
  
---

## Návod krok-za-krokem (průvodce)

1. **Vítejte** → **Další**  
<img width="500" height="388" alt="image" src="https://github.com/user-attachments/assets/47f86d9f-ded4-44bd-8d7b-9c149334501d" /><br/>
2. **Zvolte cílové umístění** → ponechte detekovanou cestu nebo zvolte kořen hry (**Procházet…**)  
<img width="500" height="389" alt="image" src="https://github.com/user-attachments/assets/566efe91-f4cd-4804-a682-155acfc19357" /><br/>
3. **Instalovat** → probíhá import do LODů a kopie souborů  
<img width="502" height="391" alt="image" src="https://github.com/user-attachments/assets/ddd75a40-7b50-4448-824b-1f69fd918286" /><br/>
4. **Dokončit** a můžete hrát  
<img width="501" height="388" alt="image" src="https://github.com/user-attachments/assets/e0273817-40e6-44be-871a-b80322d21acf" /><br/>


> Pokud u zvolené složky chybí podadresář **`data`**, průvodce na to upozorní.

---

## Kompatibilita

- **Edice:** jakákoli **Complete** (SoD + AB) – GOG / CD / Ubisoft / Epic  
- **OS:** Windows **XP–11** (32/64-bit)  
- **HD Mod / jiné mody:** patch mění obsah LODů a `Maps`. Používáte-li mody se stejnými soubory, aplikujte češtinu jako poslední, případně po patchi mod znovu nainstalujte.

---

## Řešení problémů

- **Hra se nenašla** – vyberte kořen ručně (musí obsahovat složku **`data`**).  
- **Přístup odepřen** – spusťte instalátor jako **Správce**.  

---

## Pro nadšence: jak na to ze zdrojů

V repozitáři jsou přiloženy:
- **`Installer.iss`** – skript pro Inno Setup (instalátor).  
- **`import.cmd`** – jednoduchý skript, který umí **ručně** provést import do LODů pomocí `lodimport.exe`.

### Varianta A – zkompilujte si instalátor

- Doporučeno **Inno Setup 6** (nebo **Inno Setup 5 Unicode** pro podporu Windows XP).  
- Struktura repozitáře počítá s tím, že **payload (složky `H3…`, `maps`, PDF, `lodimport.exe`) leží v kořeni** vedle `Installer.iss`.  
  Instalátor vše dočasně rozbalí do `{tmp}` a pak provede patch.

### Varianta B – ruční patch (CMD)

- Otevřete příkazový řádek, spusťte **`import.cmd`** a zadejte cestu ke kořeni hry.  
- Skript:
  - najde LODy v `…\data` a do nich naimportuje připravené soubory,  
  - nahradí složku `Maps`,  
  - zkopíruje PDF a `README.txt`.
  - zkopíruje #cz.ini.
- **Kompatibilita:** funguje na **Windows 2000 / XP a novějších**.  
  (Na **Windows 95/98/ME** lze skript převést na `.BAT` nebo provést import ručně pomocí `lodimport.exe`.)

---

## Jak to funguje uvnitř (stručně)

- Installer/skript projde podsložky (např. `H3bitmap`, `H3sprite`, `H3ab_bmp`, `H3ab_spr`), pro každou z nich hledá odpovídající `*.lod` v `…\data` a na každý nalezený soubor zavolá:
  ```
  lodimport.exe "<cesta>\data\<jmeno>.lod" "<cesta_k_souboru_k_importu>"
  ```
- Poté vyčistí a nahradí `Maps`, aktualizuje PDF manuály a `README.txt`.

---

## Licence a poděkování

- Překlad: **CD Projekt** (oficiální čeština).  
- Hra: © New World Computing / 3DO / Ubisoft (příslušným vlastníkům).  
- Tento projekt distribuuje pouze lokalizační soubory a nástroje potřebné k jejich aplikaci.

---

## Changelog

- **v1.0.1** – instalátor s průvodcem, překlad pro HD Launcher, opravy překladu.  
- **v1.0.0** – první veřejná verze patcheru (CMD).
