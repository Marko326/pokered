MainMenu:
; Check save file
	call InitOptions
	xor a
	ld [wOptionsInitialized], a
	inc a
	ld [wSaveFileStatus], a
	call CheckForPlayerNameInSRAM
	jr nc, .mainMenuLoop

	predef TryLoadSaveFile
	; wOptions is part of the normal save data. If Music Off was saved, stop
	; the title BGM now, after the regular save loader has restored WRAM.
	ld a, [wOptions]
	bit BIT_MUSIC_OFF, a
	jr z, .mainMenuLoop
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound

.mainMenuLoop
	ld c, 20
	call DelayFrames
	xor a ; LINK_STATE_NONE
	ld [wLinkState], a
	ld hl, wPartyAndBillsPCSavedMenuItem
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wDefaultMap], a
	ld hl, wStatusFlags4
	res BIT_LINK_CONNECTED, [hl]
	call ClearScreen
	call RunDefaultPaletteCommand
	call LoadTextBoxTilePatterns
	call LoadFontTilePatterns
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	ld a, [wSaveFileStatus]
	cp 1
	jr z, .noSaveFile
; there's a save file
	hlcoord 0, 0
	ld b, 6
	ld c, 13
	call TextBoxBorder
	hlcoord 2, 2
	ld de, ContinueText
	call PlaceString
	jr .next2
.noSaveFile
	hlcoord 0, 0
	ld b, 4
	ld c, 13
	call TextBoxBorder
	hlcoord 2, 2
	ld de, NewGameText
	call PlaceString
.next2
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call UpdateSprites
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld [wMenuJoypadPollCount], a
	inc a
	ld [wTopMenuItemX], a
	inc a
	ld [wTopMenuItemY], a
	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuWatchedKeys], a
	ld a, [wSaveFileStatus]
	ld [wMaxMenuItem], a
	call HandleMenuInput
	bit B_PAD_B, a
	jp nz, DisplayTitleScreen ; if so, go back to the title screen
	ld c, 20
	call DelayFrames
	ld a, [wCurrentMenuItem]
	ld b, a
	ld a, [wSaveFileStatus]
	cp 2
	jp z, .skipInc
; If there's no save file, increment the current menu item so that the numbers
; are the same whether or not there's a save file.
	inc b
.skipInc
	ld a, b
	and a
	jr z, .choseContinue
	cp 1
	jp z, StartNewGame
	; Bit 7 clear = Options opened from the title/main menu.
	xor a
	ld [wOptionsMenuPage], a
	call DisplayOptionMenu
	ld a, TRUE
	ld [wOptionsInitialized], a
	jp .mainMenuLoop
.choseContinue
	call DisplayContinueGameInfo
	ld hl, wCurrentMapScriptFlags
	set BIT_CUR_MAP_LOADED_1, [hl]
.inputLoop
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ldh [hJoyHeld], a
	call Joypad
	ldh a, [hJoyHeld]
	bit B_PAD_A, a
	jr nz, .pressedA
	bit B_PAD_B, a
	jp nz, .mainMenuLoop
	jr .inputLoop
.pressedA
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerDirection], a
	ld c, 10
	call DelayFrames
	ld a, [wNumHoFTeams]
	and a
	jp z, SpecialEnterMap
	ld a, [wCurMap]
	cp HALL_OF_FAME
	jp nz, SpecialEnterMap
	xor a
	ld [wDestinationMap], a
	ld hl, wStatusFlags6
	set BIT_FLY_OR_DUNGEON_WARP, [hl]
	call PrepareForSpecialWarp
	jp SpecialEnterMap

InitOptions:
	ld a, 1 << BIT_FAST_TEXT_DELAY
	ld [wLetterPrintingDelayFlags], a
	ld a, TEXT_DELAY_MEDIUM
	ld [wOptions], a
	ret

LinkMenu:
	xor a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wStatusFlags4
	set BIT_LINK_CONNECTED, [hl]
	ld hl, LinkMenuEmptyText
	call PrintText
	call SaveScreenTilesToBuffer1
	ld hl, WhereWouldYouLikeText
	call PrintText
	hlcoord 5, 5
	ld b, $6
	ld c, $d
	call TextBoxBorder
	call UpdateSprites
	hlcoord 7, 7
	ld de, CableClubOptionsText
	call PlaceString
	xor a
	ld [wUnusedLinkMenuByte], a
	ld [wCableClubDestinationMap], a
	ld hl, wTopMenuItemY
	ld a, 7
	ld [hli], a
	ASSERT wTopMenuItemY + 1 == wTopMenuItemX
	ld a, 6
	ld [hli], a
	ASSERT wTopMenuItemX + 1 == wCurrentMenuItem
	xor a
	ld [hli], a
	inc hl
	ASSERT wCurrentMenuItem + 2 == wMaxMenuItem
	ld a, 2
	ld [hli], a
	ASSERT wMaxMenuItem + 1 == wMenuWatchedKeys
	ASSERT 2 + 1 == PAD_A | PAD_B
	inc a
	ld [hli], a
	ASSERT wMenuWatchedKeys + 1 == wLastMenuItem
	xor a
	ld [hl], a
.waitForInputLoop
	call HandleMenuInput
	and PAD_A | PAD_B
	add a
	add a
	ld b, a
	ld a, [wCurrentMenuItem]
	add b
	add $d0
	ld [wLinkMenuSelectionSendBuffer], a
	ld [wLinkMenuSelectionSendBuffer + 1], a
.exchangeMenuSelectionLoop
	call Serial_ExchangeLinkMenuSelection
	ld a, [wLinkMenuSelectionReceiveBuffer]
	ld b, a
	and $f0
	cp $d0
	jr z, .checkEnemyMenuSelection
	ld a, [wLinkMenuSelectionReceiveBuffer + 1]
	ld b, a
	and $f0
	cp $d0
	jr nz, .exchangeMenuSelectionLoop
.checkEnemyMenuSelection
	ld a, b
	and $c ; did the enemy press A or B?
	jr nz, .enemyPressedAOrB
; the enemy didn't press A or B
	ld a, [wLinkMenuSelectionSendBuffer]
	and $c ; did the player press A or B?
	jr z, .waitForInputLoop ; if neither the player nor the enemy pressed A or B, try again
	jr .doneChoosingMenuSelection ; if the player pressed A or B but the enemy didn't, use the player's selection
.enemyPressedAOrB
	ld a, [wLinkMenuSelectionSendBuffer]
	and $c ; did the player press A or B?
	jr z, .useEnemyMenuSelection ; if the enemy pressed A or B but the player didn't, use the enemy's selection
; the enemy and the player both pressed A or B
; The gameboy that is clocking the connection wins.
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .doneChoosingMenuSelection
.useEnemyMenuSelection
	ld a, b
	ld [wLinkMenuSelectionSendBuffer], a
	and $3
	ld [wCurrentMenuItem], a
.doneChoosingMenuSelection
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr nz, .skipStartingTransfer
	call DelayFrame
	call DelayFrame
	ld a, SC_START | SC_INTERNAL
	ldh [rSC], a
.skipStartingTransfer
	ld b, ' '
	ld c, ' '
	ld d, '▷'
	ld a, [wLinkMenuSelectionSendBuffer]
	and PAD_B << 2 ; was B button pressed?
	jr nz, .updateCursorPosition
; A button was pressed
	ld a, [wCurrentMenuItem]
	cp $2
	jr z, .updateCursorPosition
	ld c, d
	ld d, b
	dec a
	jr z, .updateCursorPosition
	ld b, c
	ld c, d
.updateCursorPosition
	ld a, b
	ldcoord_a 6, 7
	ld a, c
	ldcoord_a 6, 9
	ld a, d
	ldcoord_a 6, 11
	ld c, 40
	call DelayFrames
	call LoadScreenTilesFromBuffer1
	ld a, [wLinkMenuSelectionSendBuffer]
	and PAD_B << 2 ; was B button pressed?
	jr nz, .choseCancel ; cancel if B pressed
	ld a, [wCurrentMenuItem]
	cp $2
	jr z, .choseCancel
	xor a
	ld [wWalkBikeSurfState], a ; start walking
	ld a, [wCurrentMenuItem]
	and a
	ld a, COLOSSEUM
	jr nz, .next
	ld a, TRADE_CENTER
.next
	ld [wCableClubDestinationMap], a
	ld hl, PleaseWaitText
	call PrintText
	ld c, 50
	call DelayFrames
	ld hl, wStatusFlags6
	res BIT_DEBUG_MODE, [hl]
	ld a, [wDefaultMap]
	ld [wDestinationMap], a
	call PrepareForSpecialWarp
	ld c, 20
	call DelayFrames
	xor a
	ld [wMenuJoypadPollCount], a
	ld [wSerialExchangeNybbleSendData], a
	inc a ; LINK_STATE_IN_CABLE_CLUB
	ld [wLinkState], a
	ld [wEnteringCableClub], a
	jr SpecialEnterMap
.choseCancel
	xor a
	ld [wMenuJoypadPollCount], a
	vc_hook Wireless_net_stop
	call Delay3
	call CloseLinkConnection
	ld hl, LinkCanceledText
	vc_hook Wireless_net_end
	call PrintText
	ld hl, wStatusFlags4
	res BIT_LINK_CONNECTED, [hl]
	ret

WhereWouldYouLikeText:
	text_far _WhereWouldYouLikeText
	text_end

PleaseWaitText:
	text_far _PleaseWaitText
	text_end

LinkCanceledText:
	text_far _LinkCanceledText
	text_end

StartNewGame:
	ld hl, wStatusFlags6
	; Ensure debug mode is not used when starting a regular new game.
	; Debug mode persists in saved games for both debug and non-debug builds, and is
	; only reset here by the main menu.
	res BIT_DEBUG_MODE, [hl]
	; fallthrough
StartNewGameDebug:
	call OakSpeech
	ld c, 20
	call DelayFrames

; enter map after using a special warp or loading the game from the main menu
SpecialEnterMap::
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyHeld], a
	ldh [hJoy5], a
	ld [wCableClubDestinationMap], a
	ld hl, wStatusFlags6
	set BIT_GAME_TIMER_COUNTING, [hl]
	call ResetPlayerSpriteData
	ld c, 20
	call DelayFrames
	ld a, [wEnteringCableClub]
	and a
	ret nz
	jp EnterMap

ContinueText:
	db "CONTINUE"
	next ""
	; fallthrough

NewGameText:
	db   "NEW GAME"
	next "OPTION@"

CableClubOptionsText:
	db   "TRADE CENTER"
	next "COLOSSEUM"
	next "CANCEL@"

DisplayContinueGameInfo:
	xor a
	ldh [hAutoBGTransferEnabled], a
	hlcoord 4, 7
	ld b, 8
	ld c, 14
	call TextBoxBorder
	hlcoord 5, 9
	ld de, SaveScreenInfoText
	call PlaceString
	hlcoord 12, 9
	ld de, wPlayerName
	call PlaceString
	hlcoord 17, 11
	call PrintNumBadges
	hlcoord 16, 13
	call PrintNumOwnedMons
	hlcoord 13, 15
	call PrintPlayTime
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ld c, 30
	jp DelayFrames

PrintSaveScreenText:
	xor a
	ldh [hAutoBGTransferEnabled], a
	hlcoord 4, 0
	ld b, $8
	ld c, $e
	call TextBoxBorder
	call LoadTextBoxTilePatterns
	call UpdateSprites
	hlcoord 5, 2
	ld de, SaveScreenInfoText
	call PlaceString
	hlcoord 12, 2
	ld de, wPlayerName
	call PlaceString
	hlcoord 17, 4
	call PrintNumBadges
	hlcoord 16, 6
	call PrintNumOwnedMons
	hlcoord 13, 8
	call PrintPlayTime
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	ld c, 30
	jp DelayFrames

PrintNumBadges:
	push hl
	ld hl, wObtainedBadges
	ld b, $1
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 2
	jp PrintNumber

PrintNumOwnedMons:
	push hl
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 3
	jp PrintNumber

PrintPlayTime:
	ld de, wPlayTimeHours
	lb bc, 1, 3
	call PrintNumber
	ld [hl], $6d
	inc hl
	ld de, wPlayTimeMinutes
	lb bc, LEADING_ZEROES | 1, 2
	jp PrintNumber

SaveScreenInfoText:
	db   "PLAYER"
	next "BADGES    "
	next "#DEX    "
	next "TIME@"

DisplayOptionMenu:
	ld hl, wOptionsMenuPage
	res 0, [hl] ; always open on page 1; keep bit 7 (caller source)
	call .drawPage1
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ASSERT BIT_FAST_TEXT_DELAY == 0
	inc a ; 1 << BIT_FAST_TEXT_DELAY
	ld [wLetterPrintingDelayFlags], a
	call SetCursorPositionsFromOptions
	; Open the menu on the Page selector.
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	ld a, $01
	ldh [hAutoBGTransferEnabled], a
	call Delay3
.loop
	call PlaceMenuCursor
	call SetOptionsFromCursorPositions
.getJoypadStateLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and ~PAD_SELECT ; any key besides select pressed?
	jr z, .getJoypadStateLoop
	bit B_PAD_B, b
	jr nz, .exitMenu
	bit B_PAD_START, b
	jr nz, .exitMenu
	bit B_PAD_A, b
	jr z, .checkDirectionKeys
	; A does not activate Page; B or Start exits the options menu.
	jp .loop
.exitMenu
	ld a, SFX_PRESS_AB
	call PlaySound
	ret
.eraseOldMenuCursor
	ld [wTopMenuItemX], a
	call EraseMenuCursor
	jp .loop
.checkDirectionKeys
	ld a, [wOptionsMenuPage]
	bit 0, a
	jp nz, .checkPage2DirectionKeys

; Page 1: Text Speed, Battle Animation, Battle Style, Page.
	ld a, [wTopMenuItemY]
	bit B_PAD_DOWN, b
	jr nz, .page1DownPressed
	bit B_PAD_UP, b
	jr nz, .page1UpPressed
	cp 8
	jr z, .cursorInBattleAnimation
	cp 13
	jr z, .cursorInBattleStyle
	cp 16
	jr z, .cursorOnPage1Selector
.cursorInTextSpeed
	bit B_PAD_LEFT, b
	jp nz, .pressedLeftInTextSpeed
	jp .pressedRightInTextSpeed
.page1DownPressed
	cp 3
	jr z, .page1SelectBattleAnimation
	cp 8
	jr z, .page1SelectBattleStyle
	cp 13
	jr z, .page1SelectPage
	jr .page1SelectTextSpeed
.page1UpPressed
	cp 3
	jr z, .page1SelectPage
	cp 8
	jr z, .page1SelectTextSpeed
	cp 13
	jr z, .page1SelectBattleAnimation
	jr .page1SelectBattleStyle
.page1SelectTextSpeed
	ld a, 3
	ld [wTopMenuItemY], a
	ld a, [wOptionsTextSpeedCursorX]
	jr .storePage1CursorX
.page1SelectBattleAnimation
	ld a, 8
	ld [wTopMenuItemY], a
	ld a, [wOptionsBattleAnimCursorX]
	jr .storePage1CursorX
.page1SelectBattleStyle
	ld a, 13
	ld [wTopMenuItemY], a
	ld a, [wOptionsBattleStyleCursorX]
	jr .storePage1CursorX
.page1SelectPage
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
.storePage1CursorX
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop
.cursorInBattleAnimation
	ld a, [wOptionsBattleAnimCursorX]
	xor 1 ^ 10
	ld [wOptionsBattleAnimCursorX], a
	jp .eraseOldMenuCursor
.cursorInBattleStyle
	ld a, [wOptionsBattleStyleCursorX]
	xor 1 ^ 10
	ld [wOptionsBattleStyleCursorX], a
	jp .eraseOldMenuCursor
.cursorOnPage1Selector
	bit B_PAD_RIGHT, b
	jp nz, .showPage2
	jp .loop
.pressedLeftInTextSpeed
	ld a, [wOptionsTextSpeedCursorX]
	cp 1
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromSlowToMedium
	sub 6
	jr .updateTextSpeedXCoord
.fromSlowToMedium
	sub 7
	jr .updateTextSpeedXCoord
.pressedRightInTextSpeed
	ld a, [wOptionsTextSpeedCursorX]
	cp 14
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromFastToMedium
	add 7
	jr .updateTextSpeedXCoord
.fromFastToMedium
	add 6
.updateTextSpeedXCoord
	ld [wOptionsTextSpeedCursorX], a
	jp .eraseOldMenuCursor

; Page 2: Music and Page. Left/right on Music toggles On/Off.
; Left on the Page selector returns to page 1.
.checkPage2DirectionKeys
	ld a, [wTopMenuItemY]
	bit B_PAD_DOWN, b
	jr nz, .page2DownPressed
	bit B_PAD_UP, b
	jr nz, .page2UpPressed
	cp 16
	jr z, .cursorOnPage2Selector
.cursorInMusic
	ld a, [wOptionsMusicCursorX]
	xor 1 ^ 10
	ld [wOptionsMusicCursorX], a
	jp .eraseOldMenuCursor
.page2DownPressed
	cp 3
	jr nz, .page2SelectMusic
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop
.page2UpPressed
	cp 16
	jr nz, .page2SelectPage
.page2SelectMusic
	ld a, 3
	ld [wTopMenuItemY], a
	ld a, [wOptionsMusicCursorX]
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop
.page2SelectPage
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop
.cursorOnPage2Selector
	bit B_PAD_LEFT, b
	jp nz, .showPage1
	jp .loop

.showPage2
	ld hl, wOptionsMenuPage
	set 0, [hl]
	; Build the new page in wTileMap before re-enabling auto transfer to avoid
	; a blank-frame flash during ClearScreen.
	xor a
	ldh [hAutoBGTransferEnabled], a
	call ClearScreen
	call .drawPage2
	call .placePage2Arrows
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	jp .loop

.showPage1
	ld hl, wOptionsMenuPage
	res 0, [hl]
	xor a
	ldh [hAutoBGTransferEnabled], a
	call ClearScreen
	call .drawPage1
	call SetCursorPositionsFromOptions
	ld a, 16
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	jp .loop

.drawPage1
	hlcoord 0, 0
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 0, 5
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 0, 10
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 1, 1
	ld de, TextSpeedOptionText
	call PlaceString
	hlcoord 1, 6
	ld de, BattleAnimationOptionText
	call PlaceString
	hlcoord 1, 11
	ld de, BattleStyleOptionText
	call PlaceString
	hlcoord 2, 16
	ld de, OptionMenuPageText
	call PlaceString
	hlcoord 16, 16
	ld de, OptionMenuPage1Text
	jp PlaceString

.drawPage2
	hlcoord 0, 0
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 0, 5
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 0, 10
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 1, 1
	ld de, MusicOptionText
	call PlaceString
	hlcoord 2, 16
	ld de, OptionMenuPageText
	call PlaceString
	hlcoord 16, 16
	ld de, OptionMenuPage2Text
	jp PlaceString

.placePage2Arrows
	hlcoord 0, 3
	ld a, [wOptionsMusicCursorX]
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], '▷'
	hlcoord 1, 16
	ld [hl], '▷'
	ret

TextSpeedOptionText:
	db   "TEXT SPEED"
	next " FAST  MEDIUM SLOW@"

BattleAnimationOptionText:
	db   "BATTLE ANIMATION"
	next " ON       OFF@"

BattleStyleOptionText:
	db   "BATTLE STYLE"
	next " SHIFT    SET@"

MusicOptionText:
	db   "MUSIC"
	next " ON       OFF@"

OptionMenuPageText:
	db "PAGE@"

OptionMenuPage1Text:
	db "1/2@"

OptionMenuPage2Text:
	db "2/2@"

; sets wOptions according to the current cursor positions
SetOptionsFromCursorPositions:
	ld a, [wOptions]
	and 1 << BIT_MUSIC_OFF
	ld e, a ; remember old Music state so transitions run only once

	ld hl, TextSpeedOptionData
	ld a, [wOptionsTextSpeedCursorX]
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr z, .textSpeedMatchFound
	inc hl
	jr .loop
.textSpeedMatchFound
	ld a, [hl]
	ld d, a
	ld a, [wOptionsBattleAnimCursorX]
	dec a
	jr z, .battleAnimationOn
; battle animation Off
	set BIT_BATTLE_ANIMATION, d
	jr .checkBattleStyle
.battleAnimationOn
	res BIT_BATTLE_ANIMATION, d
.checkBattleStyle
	ld a, [wOptionsBattleStyleCursorX]
	dec a
	jr z, .battleStyleShift
; battle style Set
	set BIT_BATTLE_SHIFT, d
	jr .checkMusic
.battleStyleShift
	res BIT_BATTLE_SHIFT, d
.checkMusic
	ld a, [wOptionsMusicCursorX]
	dec a
	jr z, .musicOn
.musicOff
	set BIT_MUSIC_OFF, d
	jr .storeOptions
.musicOn
	res BIT_MUSIC_OFF, d
.storeOptions
	ld a, d
	ld [wOptions], a
	and 1 << BIT_MUSIC_OFF
	cp e
	ret z
	and a
	jr z, .enableMusic
; Stop the currently playing BGM once. While Music Off remains active,
; Home/PlaySound filters future BGM requests but still lets SFX through.
	xor a
	ld [wAudioFadeOutControl], a
	dec a ; SFX_STOP_ALL_MUSIC
	jp PlaySound
.enableMusic
	; From the title/main menu, restart the title music. From the in-game
	; Start menu, restart the correct map/bike/surf music.
	ld a, [wOptionsMenuPage]
	bit 7, a
	jr nz, .enableInGameMusic
	ld c, BANK(Music_TitleScreen)
	ld a, MUSIC_TITLE_SCREEN
	jp PlayMusic
.enableInGameMusic
	xor a
	ld [wLastMusicSoundID], a
	jp PlayDefaultMusic

; reads wOptions and places menu cursors in the correct positions
SetCursorPositionsFromOptions:
	ld hl, TextSpeedOptionData + 1
	ld a, [wOptions]
	and TEXT_DELAY_MASK
	ld c, a
	ld de, 2
	call IsInArray
	dec hl
	ld a, [hl]
	ld [wOptionsTextSpeedCursorX], a
	hlcoord 0, 3
	call .placeUnfilledRightArrow

	ld a, [wOptions]
	bit BIT_BATTLE_ANIMATION, a
	ld a, 1
	jr z, .storeBattleAnimationCursorX
	ld a, 10
.storeBattleAnimationCursorX
	ld [wOptionsBattleAnimCursorX], a
	hlcoord 0, 8
	call .placeUnfilledRightArrow

	ld a, [wOptions]
	bit BIT_BATTLE_SHIFT, a
	ld a, 1
	jr z, .storeBattleStyleCursorX
	ld a, 10
.storeBattleStyleCursorX
	ld [wOptionsBattleStyleCursorX], a
	hlcoord 0, 13
	call .placeUnfilledRightArrow

	ld a, [wOptions]
	bit BIT_MUSIC_OFF, a
	ld a, 1
	jr z, .storeMusicCursorX
	ld a, 10
.storeMusicCursorX
	ld [wOptionsMusicCursorX], a

	hlcoord 1, 16
	ld [hl], '▷'
	ret
.placeUnfilledRightArrow
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], '▷'
	ret

; table that indicates how the 3 text speed options affect frame delays
; Format:
; 00: X coordinate of menu cursor
; 01: delay after printing a letter (in frames)
TextSpeedOptionData:
	db 14, TEXT_DELAY_SLOW
	db  7, TEXT_DELAY_MEDIUM
	db  1, TEXT_DELAY_FAST
	db  7, -1 ; end (default X coordinate)

CheckForPlayerNameInSRAM:
; Check if the player name data in SRAM has a string terminator character
; (indicating that a name may have been saved there) and return whether it does
; in carry.
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	ld a, BMODE_ADVANCED
	ld [rBMODE], a
	ASSERT BANK(sPlayerName) == BMODE_ADVANCED
	ld [rRAMB], a
	ld b, NAME_LENGTH
	ld hl, sPlayerName
.loop
	ld a, [hli]
	cp '@'
	jr z, .found
	dec b
	jr nz, .loop
; not found
	xor a
	ld [rRAMG], a
	ld [rBMODE], a
	and a
	ret
.found
	xor a
	ld [rRAMG], a
	ld [rBMODE], a
	scf
	ret
