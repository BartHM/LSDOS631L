;****************************************************************;* Filename: SYS13/ASM						*;* Rev Date: 30 Nov 97						*;* Revision: 6.3.1						*;****************************************************************;* Place-holder for an extended command interpreter.  This is	*;* only here to prevent errors and stuff.			*;****************************************************************;	TITLE	<SYS13 - LS-DOS 6.3>;LF	EQU	10CR	EQU	13;*GET	COPYCOM;	ORG	1E00HSYS13	JR	START	DC	32,0		; SlackSTART	AND	70H		; Strip bit 7	CP	70H		; Go if 0111,0000	JP	Z,NOCMD		;   to No * commandNOSYS13	LD	A,101		; Get flags	RST	28H	LD	(IY+'E'-'A'),0	; Reset ECI flag	LD	HL,NXCI$	; "No ECI present...	LD	A,12		; Display and log it	RST	28H	XOR	A	RET;NOCMD	LD	HL,NOCMD$	; "No sys13...	LD	A,12		; Display and log it	RST	28H	XOR	A	RET;NXCI$	DB	'No Extended Command Interpreter Present, as SYS13 ',LF,CRNOCMD$	DB	'No command <*> present, as SYS13 ',LF,CR;*LIST OFF	DC	500,0*LIST ON;	END	SYS13