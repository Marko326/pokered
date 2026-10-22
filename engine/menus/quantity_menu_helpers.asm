; ROM-1.0.3: Move quantity selection out of HOME to free ROM0 space.
; This helper lives in bank $2D; its private strings stay in the same bank.
DisplayChooseQuantityMenu_::
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
	call JoypadLowSensitivity
	ldh a, [hJoyPressed] ; newly pressed buttons
	bit B_PAD_A, a
	jp nz, .buttonAPressed
	bit B_PAD_B, a
	jp nz, .buttonBPressed
	bit B_PAD_UP, a
	jr nz, .incrementQuantity
	bit B_PAD_DOWN, a
	jr nz, .decrementQuantity
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
	ld c, 3 | LEADING_ZEROES | MONEY_SIGN
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
	ld e, a
	ret
.buttonBPressed ; the player chose to cancel the transaction
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	ld a, $ff
	ld e, a
	ret

InitialQuantityText::
	db "×01@"

SpacesBetweenQuantityAndPriceText::
	db "      @"
