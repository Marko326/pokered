; ROM-1.3: Move the CHS quantity menu to spare ROMX bank $2D.
DisplayChooseQuantityMenu_::
; Preserve the caller's shared input timer/output; quantity repeat is local.
	ldh a, [hFrameCounter]
	push af
	ldh a, [hJoy5]
	push af
	ld a, 40 ; Ruby quantity picker initial repeat delay
	ldh [hFrameCounter], a
; text box dimensions/coordinates for just quantity
	hlcoord 15, 9
	ld b, 1 ; height
	ld c, 3 ; width
	ld a, [wListMenuID]
	cp PRICEDITEMLISTMENU
	jr nz, .drawTextBox
; text box dimensions/coordinates for quantity and price
	hlcoord 7, 9
	ld b, 1  ; height
	ld c, 11 ; width
.drawTextBox
	call TextBoxBorder
	hlcoord 16, 10
	ld a, [wListMenuID]
	cp PRICEDITEMLISTMENU
	jr nz, .printInitialQuantity
	hlcoord 8, 10
.printInitialQuantity
	ld de, InitialQuantityText
	call PlaceString
	xor a
	ld [wItemQuantity], a ; initialize current quantity to 0
	jp .incrementQuantity
.waitForKeyPressLoop
	call .readQuantityMenuKeys
	ldh a, [hJoyPressed] ; A/B remain edge-triggered, like Ruby's newKeys
	bit BIT_A_BUTTON, a
	jp nz, .buttonAPressed
	bit BIT_B_BUTTON, a
	jp nz, .buttonBPressed
	ldh a, [hJoy5] ; directions include Ruby-style held-key repeats
	and D_UP | D_DOWN | D_LEFT | D_RIGHT
	cp D_UP
	jr z, .incrementQuantity
	cp D_DOWN
	jr z, .decrementQuantity
	cp D_RIGHT
	jr z, .incrementQuantityBy10
	cp D_LEFT
	jr z, .decrementQuantityBy10
	jr .waitForKeyPressLoop
.incrementQuantity
	ld a, [wMaxItemQuantity]
	inc a
	ld b, a
	ld hl, wItemQuantity ; current quantity
	inc [hl]
	ld a, [hl]
	cp b
	jr nz, .handleNewQuantity
; wrap to 1 if the player goes above the max quantity
	ld a, 1
	ld [hl], a
	jr .handleNewQuantity
.decrementQuantity
	ld hl, wItemQuantity ; current quantity
	dec [hl]
	jr nz, .handleNewQuantity
; wrap to the max quantity if the player goes below 1
	ld a, [wMaxItemQuantity]
	ld [hl], a
	jr .handleNewQuantity
.decrementQuantityBy10
; Left subtracts ten and clamps at the minimum quantity, matching Ruby.
	ld hl, wItemQuantity
	ld a, [hl]
	cp 11
	jr nc, .subtractTen
	ld a, 1
	ld [hl], a
	jr .handleNewQuantity
.subtractTen
	sub 10
	ld [hl], a
	jr .handleNewQuantity
.incrementQuantityBy10
; Right adds ten and clamps at the selected item's maximum quantity.
	ld hl, wItemQuantity
	ld a, [hl]
	add 10
	ld b, a
	ld a, [wMaxItemQuantity]
	cp b
	jr nc, .storeIncreasedQuantity
	ld b, a
.storeIncreasedQuantity
	ld [hl], b
.handleNewQuantity
	hlcoord 17, 10
	ld a, [wListMenuID]
	cp PRICEDITEMLISTMENU
	jr nz, .printQuantity
.printPrice
	ld c, $03
	ld a, [wItemQuantity]
	ld b, a
	ld hl, hMoney ; total price
; initialize total price to 0
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
.addLoop ; loop to multiply the individual price by the quantity to get the total price
	ld de, hMoney + 2
	ld hl, hItemPrice + 2
	push bc
	predef AddBCDPredef ; add the individual price to the current sum
	pop bc
	dec b
	jr nz, .addLoop
	ldh a, [hHalveItemPrices]
	and a ; should the price be halved (for selling items)?
	jr z, .skipHalvingPrice
	xor a
	ldh [hDivideBCDDivisor], a
	ldh [hDivideBCDDivisor + 1], a
	ld a, $02
	ldh [hDivideBCDDivisor + 2], a
	predef DivideBCDPredef3 ; halves the price
; store the halved price
	ldh a, [hDivideBCDQuotient]
	ldh [hMoney], a
	ldh a, [hDivideBCDQuotient + 1]
	ldh [hMoney + 1], a
	ldh a, [hDivideBCDQuotient + 2]
	ldh [hMoney + 2], a
.skipHalvingPrice
	hlcoord 12, 10
	ld de, SpacesBetweenQuantityAndPriceText
	call PlaceString
	ld de, hMoney ; total price
	ld c, $a3
	call PrintBCDNumber
	hlcoord 9, 10
.printQuantity
	ld de, wItemQuantity ; current quantity
	lb bc, LEADING_ZEROES | 1, 2 ; 1 byte, 2 digits
	call PrintNumber
	jp .waitForKeyPressLoop
.buttonAPressed ; the player chose to make the transaction
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	ld e, a ; keep the selection across the Bank restore
	jr .restoreInputState
.buttonBPressed ; the player chose to cancel the transaction
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	ld a, $ff
	ld e, a ; keep the selection across the Bank restore
.restoreInputState
	pop af
	ldh [hJoy5], a
	pop af
	ldh [hFrameCounter], a
	ret

; Reproduce Ruby's newAndRepeatedKeys behavior locally so no other menu's
; repeat timing or input policy changes.
.readQuantityMenuKeys
	call Joypad
	ldh a, [hJoyPressed]
	and a
	jr nz, .newQuantityMenuKey
	ldh a, [hJoyReleased]
	and a
	jr nz, .resetQuantityMenuDelay
	ldh a, [hJoyHeld]
	and a
	jr z, .resetQuantityMenuDelay
	ldh a, [hFrameCounter]
	and a
	jr z, .repeatQuantityMenuKeys
	xor a
	ldh [hJoy5], a
	ret
.newQuantityMenuKey
	ldh a, [hJoyPressed]
	ldh [hJoy5], a
	ld a, 40 ; Ruby: first repeat after 40 frames
	ldh [hFrameCounter], a
	ret
.resetQuantityMenuDelay
	xor a
	ldh [hJoy5], a
	ld a, 40
	ldh [hFrameCounter], a
	ret
.repeatQuantityMenuKeys
	ldh a, [hJoyHeld]
	ldh [hJoy5], a
	ld a, 5 ; Ruby: repeat every 5 frames
	ldh [hFrameCounter], a
	ret

InitialQuantityText::
	db "×01@"

SpacesBetweenQuantityAndPriceText::
	db "      @"

