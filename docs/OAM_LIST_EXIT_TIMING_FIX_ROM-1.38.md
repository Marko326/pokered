# ROM-1.38 OAM list-exit timing correction

Date: 2026-11-06
Status: source patch prepared; handheld/DMG/CGB verification pending.

## Evidence

The user supplied a frame showing a map character sprite at the seam between the START Bag's upper item-list window and lower description window. The original video shows the same transient during the Bag-to-START return (around 15.64 s). The symptom is not a wrong description-box coordinate: overworld OAM is regenerated while the Bag tilemap is still being replaced by the parent screen.

## Changes

### START Bag

`StartMenu_Item` now keeps the prior `wUpdateSpritesEnabled` byte on the stack until the list exit path is known. On a normal cancel, it restores the saved START tilemap, restores menu input state (the restore helper waits three frames for the incremental BG transfer), loads text-box patterns, and only then calls `RestoreStartBagSpritesAndUpdate`. On the DFS-dirty return, a HOME wrapper calls `RestoreStartMenuFromItemNoWhite` to finish the parent-window copy while OAM remains disabled, then consumes the saved byte and updates sprites before returning to the unchanged Bank `$01` `JP StartMenuInputLoop`. Selecting an item pops/restores the byte at `.choseItem` before the existing USE/TOSS flow, preserving that interaction path. The Cable Club refusal path also enters with a balanced saved byte.

### Player PC

`FinishPCItemDescriptions` no longer restores OAM at the instant the list closes. It clears the description panel and changes session state `1 -> 3` (PC parent pending). Reopened PC item lists recognize state `3` and retain the original saved enable byte. The existing PlayerPC `UpdateSprites` call is moved from before menu composition to after `Delay3`; `RestoreItemListSpritesAndUpdate` restores the saved state and updates OAM only after the parent PC menu has transferred.

### Poké Mart

The list session changes `2 -> $82` when BUY/SELL returns. Reopened lists recognize `$82` and retain the original saved enable byte. OAM stays suspended through quantity prompts, result text, and BUY/SELL loops. The HOME `DisplayPokemartDialogue` wrapper calls `RestoreItemListSpritesAndUpdate` after the shop dialogue returns, then clears the session marker. The shop transaction code, prices, and list frame layout are unchanged.

## Constraints

- No new WRAM bytes; the two existing transient bytes remain in the existing padding.
- No SRAM/save-layout, bag-capacity, item-data, translation, or version-number changes.
- START's Bank `$01` code is net -1 byte in source instruction accounting; the PlayerPC Bank `$01` call is relocated with the same 3-byte call size. OAM wrappers are in HOME; session-state logic is in Bank `$30`. The existing Bank `$01` START helper gains the three-frame wait, offset by the Bank `$01` call-site reduction.
- No RGBDS compile/link, ROM generation, Git commit, or push was performed.

## Required verification

1. START Bag: B/CANCEL without scrolling; cancel after scrolling; USE/TOSS then return; an item action that closes START.
2. Player PC: Deposit, Withdraw, Toss; cancel and repeated list reopen; quantity prompt cancel and confirmation.
3. Poké Mart: BUY/SELL cancel; quantity prompt cancel/confirm; purchase/sale followed by reopening either list; quit dialogue.
4. Observe the gap between the two Bag windows and the lower description frame. No map sprite should appear there during list exit; sprites should return only after the parent UI is fully visible.
5. Check both DMG and CGB behavior and verify the original `wUpdateSpritesEnabled` value is restored.
