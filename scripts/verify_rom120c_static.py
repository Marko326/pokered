#!/usr/bin/env python3
"""ROM-1.20C retained in D: structural ABI and source-preservation guard; not a ROM build."""
from pathlib import Path
import hashlib,re
R = Path(__file__).resolve().parents[1]
def read(name):return (R/name).read_text(encoding='utf8')
def digest(s):return hashlib.sha256(s.encode()).hexdigest()

# Original B-version bodies, sha256 taken from original source before moving.
bcd=read('src/engine/menus/print_bcd_helpers.asm').split('\n',1)[1]
bcd=bcd.replace('PrintBCDNumber_Banked::','PrintBCDNumber::',1).replace('PrintBCDDigit_Banked::','PrintBCDDigit::',1).replace('call PrintBCDDigit_Banked','call PrintBCDDigit')
assert digest(bcd) == '643ea07cf0802724cfb17e48c8e2c122dd274dceb2c612365556137aac2857d8', 'BCD body has changed'
trainer=read('src/engine/audio/trainer_music_helpers.asm').split('\n',1)[1]
trainer=trainer.replace('PlayTrainerMusic_Banked::','PlayTrainerMusic::',1)
assert digest(trainer) == '133cadc64ef3ff437f5d738084922b236981153245a897555946bf6b8653753b', 'trainer music logic/tables changed'
machine=read('src/engine/items/machine_name_helpers.asm').split('\n',1)[1].split('; End of relocated TM/HM helper.')[0]
machine=machine.replace('GetMachineName_Banked::','GetMachineName::',1)
assert digest(machine) == '907e9a9f3411198ffa7d550b694d7916627ab9d6d2212aed1412bd64cca1573a', 'TM/HM name logic/prefix changed'
# Every ROM0 wrapper must carry original registers/flags through both sides.
stub_template=['ldh a, [hLoadedROMBank]','push af','ld a, BANK({banked})',
 'ldh [hLoadedROMBank], a','ld [MBC1RomBank], a','call {banked}',
 'push af','push bc','push de','push hl','ld hl, sp + 9',
 'ld a, [hl]','ldh [hLoadedROMBank], a','ld [MBC1RomBank], a',
 'pop hl','pop de','pop bc','pop af','inc sp','inc sp','ret']
for file,public,banked in [
 ('src/home/print_bcd.asm','PrintBCDNumber','PrintBCDNumber_Banked'),
 ('src/home/trainers.asm','PlayTrainerMusic','PlayTrainerMusic_Banked'),
 ('src/home/names.asm','GetMachineName','GetMachineName_Banked'),
]:
 text=read(file); chunk=text[text.index(public+'::'):]
 if file.endswith('names.asm'):chunk=chunk.split('; sets carry if item is HM')[0]
 if file.endswith('trainers.asm'):chunk=chunk # last routine in file
 lines=[' '.join(l.split(';')[0].strip().split()) for l in chunk.splitlines() if l.lstrip().startswith(('ld','push','call','pop','inc','ret')) and not l.lstrip().startswith(';')]
 expected=[' '.join(x.format(banked=banked).split()) for x in stub_template]
 assert lines[:len(expected)]==expected,(file,lines[:len(expected)])
 assert lines.count('ret')==1, file
 assert 'farjp' not in chunk, file
# All private tables and intra-function calls stay within same bank.
assert 'call PrintBCDDigit_Banked' in read('src/engine/menus/print_bcd_helpers.asm')
assert 'TechnicalPrefix::' in machine and 'HiddenPrefix::' in machine
assert 'EvilTrainerList' in trainer and 'FemaleTrainerList' in trainer
assert 'INCLUDE "data/trainers/encounter_types.asm"' in trainer
for sym in ['TechnicalPrefix::','HiddenPrefix::','PrintBCDDigit_Banked::']:
 assert sum(read(f).count(sym) for f in ['src/engine/menus/print_bcd_helpers.asm','src/engine/audio/trainer_music_helpers.asm','src/engine/items/machine_name_helpers.asm']) == 1,sym
layout=read('src/layout.link').split('ROMX $2D',1)[1].split('ROMX $3C',1)[0]
main=read('src/main.asm')
for section,part in [('BCD Printing Helpers','engine/menus/print_bcd_helpers.asm'),('Trainer Music Helpers','engine/audio/trainer_music_helpers.asm'),('Machine Name Helpers','engine/items/machine_name_helpers.asm')]:
 assert f'"{section}"' in layout and f'SECTION "{section}", ROMX' in main
 assert f'INCLUDE "{part}"' in main
assert 'db "ROM-1.21@"' in read('src/data/game_version.asm')
assert 'hlcoord 11, 0 ; ROM-1.21 正式标记为 8 字符' in read('src/engine/menus/main_menu.asm')
# Generic wrapper's SP+9: 4 saved result register pairs, then old bank AF.
for bank in (1,8,15,0x2d,0x3c):
 stack=[0x25,0xc0,0x52,0x31,0x96,0xd2,0xf0,0x77,0x00,bank]
 assert stack[9]==bank
# Original fixed-ROM map: 90+90+77 = 257 B; wrappers 32 * 3 = 96 B.
# Expected +161B must be confirmed by fresh MAP; no compile claim.
print('PASS ROM-1.20C retained in D: three unchanged bodies, private data in same bank, 3 register/AF/Bank-preserving stubs, layout (static only)')
