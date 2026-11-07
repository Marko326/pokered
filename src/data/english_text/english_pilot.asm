; Original English text copies for the LANGUAGE static-text pilot.
; Use literal POKé spellings here: '#' is a runtime dictionary command and
; expands through the CHS-localized PlacePOKeText in this build.
; No CHS XLSX sheet writes to this path, so the importer leaves it untouched.
; It is included in ROMX Bank $46; map scripts access entries through text_far.

_Route1Text2English::
	text "See those ledges"
	line "along the road?"

	para "It's a bit scary,"
	line "but you can jump"
	cont "from them."

	para "You can get back"
	line "to PALLET TOWN"
	cont "quicker that way."
	done

_ViridianCityText1English::
	text "Those POKé BALLs"
	line "at your waist!"
	cont "You have POKéMON!"

	para "It's great that"
	line "you can carry and"
	cont "use POKéMON any"
	cont "time, anywhere!"
	done
