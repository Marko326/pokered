PrintRedSNESText:
	call EnableAutoTextBoxDrawing
	tx_pre_jump RedBedroomSNESText

RedBedroomSNESText::
	text_far _RedBedroomSNESText
	text_end

OpenRedsPC:
	call EnableAutoTextBoxDrawing
	; CHS adaptation of RPP #128: keep the original Player's PC
	; item storage available before the Pokédex is received.
	; After receiving it, use a bedroom-local text-script entry.
	; TextPredefs stores a 16-bit address without its ROM Bank, so the
	; Poké Center's PokemonCenterPCText (in Hidden Objects 4) cannot be
	; dereferenced safely while this handler runs in Hidden Objects 3.
	CheckEvent EVENT_GOT_POKEDEX
	jr z, .itemsOnly
	tx_pre_jump RedBedroomPCFullText
.itemsOnly
	tx_pre_jump RedBedroomPCText

RedBedroomPCText::
	script_players_pc

RedBedroomPCFullText::
	script_pokecenter_pc
