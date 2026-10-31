#!/usr/bin/env python3
"""ROM-1.20A static-only bank-migration checks; not ROM/runtime proof."""
from pathlib import Path
import hashlib

root = Path(__file__).resolve().parents[1]
def get(path):
    return (root / path).read_text(encoding="utf-8")

yes = get('src/engine/menus/yes_no_helpers.asm')
reset = get('src/engine/overworld/reset_player_sprite_helpers.asm')
home_yes = get('src/home/yes_no.asm')
home_reset = get('src/home/reset_player_sprite.asm')
main = get('src/main.asm')
layout = get('src/layout.link')

# Body-level equality to the FLH-1.20 source before moving: only entry labels
# were renamed, with no opcodes, branching, data or comments changed.
yes_body = yes.split('; displays yes/no choice\n', 1)[1]
yes_body = ('; displays yes/no choice\n' + yes_body).replace('YesNoChoice_::', 'YesNoChoice::', 1).replace('YesNoChoicePokeCenter_::', 'YesNoChoicePokeCenter::', 1)
assert hashlib.sha256(yes_body.encode()).hexdigest() == '24d2ea3ab7d40095787c2ecec0e340a463cfa1c2c317efa1810cf6d14eb6b679'
reset_body = reset.split('ResetPlayerSpriteData_::', 1)[1]
reset_body = 'ResetPlayerSpriteData::' + reset_body
assert hashlib.sha256(reset_body.encode()).hexdigest() == 'ca15213706c3b1f11383c44b126925da8b94b2935c07cdd13fb72146d0ee964c'
assert 'YesNoChoice::\n\tfarjp YesNoChoice_' in home_yes
assert 'YesNoChoicePokeCenter::\n\tfarjp YesNoChoicePokeCenter_' in home_yes
assert 'ResetPlayerSpriteData::\n\tfarjp ResetPlayerSpriteData_' in home_reset
assert 'SECTION "Yes No Dialog Helpers", ROMX' in main
assert 'SECTION "Sprite Reset Helpers", ROMX' in main
bank = layout.split('ROMX $2D', 1)[1].split('ROMX $3C', 1)[0]
assert all(x in bank for x in ('"Yes No Dialog Helpers"', '"Sprite Reset Helpers"'))
assert any(x in get('src/data/game_version.asm') for x in ('db "ROM-1.20A@"', 'db "ROM-1.20B@"', 'db "ROM-1.21@"'))
assert any(x in get('src/engine/menus/main_menu.asm') for x in ('hlcoord 10, 0 ; ROM-1.20A 测试标记为 9 字符', 'hlcoord 10, 0 ; ROM-1.20B 测试标记为 9 字符', 'hlcoord 11, 0 ; ROM-1.21 正式标记为 8 字符'))
assert 'INCLUDE "home/reset_player_sprite.asm"' in get('src/home.asm')
assert 'INCLUDE "home/yes_no.asm"' in get('src/home.asm')
print('PASS ROM-1.20A: exact ASM-body preservation, ROM0 entry points, ROMX $2D layout (static only)')
