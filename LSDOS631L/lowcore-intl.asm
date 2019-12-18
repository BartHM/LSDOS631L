;****************************************************************
;* Filename: LOWCORE.ASM					*
;* Rev Date: 30 Nov 97						*
;* Version : 6.3.1						*
;****************************************************************
;* TRS-80 Model 4 Floppy Diskette Bootstrap Code		*
;****************************************************************
;* This is the main file use to assemble BOOT/SYS for TRSDOS6.	*
;* Assemble as a CIM file using the following command line:	*
;*    MRAS LOWCORE -GC -WE -CI					*
;****************************************************************
;
; LOWCORE/ASM - Low Memory Assignments
	TITLE	<LOWCORE - LS-DOS 6.3>
@MOD2	EQU	00		; Set MOD2 false
@MOD4	EQU	-1		; Set MOD4 true
;
;	LSDOS 6.x Low Core RAM storage assignments
;	Copyright (c) 1982 by Logical Systems, Inc.
;
;	Define switches for international or domestic
;
@GERMAN EQU	0
@FRENCH	EQU	0
	IF	@GERMAN.AND.@FRENCH
	ERR	'Can''t do both French and German'
	ENDIF
	IF	@GERMAN.OR.@FRENCH
@INTL	EQU	-1
@USA	EQU	0
@HZ50	EQU	-1
	ELSE
@INTL	EQU	0
@USA	EQU	-1
@HZ50	EQU	0
	ENDIF
;
START$	EQU	0
;
;	These EQUs are detailed in SYSRES
;
FDDINT$ EQU	0EH
PDRV$	EQU	1BH
TIMSL$	EQU	2BH
TIMER$	EQU	2CH
TIME$	EQU	TIMER$+1
DATE$	EQU	33H
INTVC$	EQU	3EH
FLGTAB$ EQU	6AH
CFLAG$	EQU	FLGTAB$+'C'-'A'
DFLAG$	EQU	FLGTAB$+'D'-'A'
IFLAG$	EQU	FLGTAB$+'I'-'A'
KFLAG$	EQU	FLGTAB$+'K'-'A'
MODOUT$ EQU	FLGTAB$+'M'-'A'
NFLAG$	EQU	FLGTAB$+'N'-'A'
OPREG$	EQU	FLGTAB$+'O'-'A'
RFLAG$	EQU	FLGTAB$+'R'-'A'
SFLAG$	EQU	FLGTAB$+'S'-'A'
VFLAG$	EQU	FLGTAB$+'V'-'A'
@KITSK	EQU	FLGTAB$+31
;
	ORG	200H+START$
;
;	Page 2 - Device Control Blocks
;
BUR$	DB	00H		;Bank use RAM
BAR$	DB	0FEH		;Bank available RAM
LBANK$	DB	20		;Dir cyl & logical bank
JCLCB$	DB	1,0,0		;Mini DCB for JCL gets
DVRHI$	DW	DVREND$		;Start of low I/O zone
KIDCB$	DB	5		;Permit CTL, GET
	DW	KIDVR
	DB	0,0,0,'KI'
DODCB$	DB	7		;Permit CTL, PUT, GET
	DW	DODVR
	DB	0,0,0,'DO'
PRDCB$	DB	6		;Permit CTL, PUT
	DW	PRDVR
	DB	0,0,0,'PR'
SIDCB$	DB	15H		;Routed to *KI
	DW	KIDCB$
	DB	0DH,0,0,'SI'
SODCB$	DB	17H		;Routed to *DO
	DW	DODCB$
	DB	0FH,0,0,'SO'
JLDCB$	DB	0AH,0,0,0AH,0,0,'JL'
S1DCB$	EQU	$		;1st spare DCB
DCBKL$	EQU	JLDCB$&0FFH+1	;Non-killable DCBs
;
;	Now load the BOOT sector code
;
*GET	BOOT4
;
	SUBTTL	'<SysInfo Section>'
;
;	Page 3 - System stack and Sysinfo section
;
STACK$	EQU	$-128		;Start stack 128 bytes low
PAUSE@	EQU	STACK$+2	;Where pause will be
;
;	Page 4 - Miscellaneous stuff
;
	DB	63H		;Operating system version
ZERO$	DB	0C9H		;Config on BOOT, yes = 0
MAXDAY$ EQU	$-1		;Max days per month
	DB	31,28,31,30,31,30,31,31,30,31,30,31
HIGH$	DS	2		;Highest available memory
PAKNAM$ DB	'LS-DOS63Level-1H'
;
;	Command line input buffer & AUTO buffer area
;
INBUF$	DB	0DH		;Input buffer - 80 bytes
	DC	79,0
;
;	System drive code tables
;
DCT$	EQU	$		;System drive code tables
	JP	FDCDVR		;Floppy drive 0
	DB	44H,0C1H,0,39,17,3-1<5+6-1,20

	JP	FDCDVR		;Floppy drive 1
	DB	44H,42H,-1,39,17,3-1<5+6-1,20

	RET
	DW	FDCDVR		;Floppy drive #2
	DB	44H,44H,-1,39,17,3-1<5+6-1,20

	RET
	DW	FDCDVR		;Floppy drive #3
	DB	44H,48H,-1,39,17,3-1<5+6-1,20

	RET			;Logical drive 4
	DW	FDCRET
	DB	0,0,0,39,0,0,0

	RET			;Logical drive 5
	DW	FDCRET
	DB	0,0,0,39,0,0,0

	RET			;Logical drive 6
	DW	FDCRET
	DB	0,0,0,39,0,0,0

	RET			;Logical drive 7
	DW	FDCRET
	DB	0,0,0,39,0,0,0
;
;	SYSINFO - miscellaneous information
;
DSKTYP$ DB	-1		;0 = DATA, <>0 = SYS
	DB	0		;Reserved
DTPMT$	DB	0		;Date prompt at boot (0-Yes)
TMPMT$	DB	0		;Time prompt at boot (0-Yes)
RSTOR$	DB	0		;Suppress restores on boot
	DB	0		;X'C5' - unknown
;
;	Note from Pete Cervasio about this byte:
;
;	Byte X'C6' of the sysinfo sector holds the backup
;	limit count for backup-limited diskettes.  If this
;	value is 0FFH, then BACKUP will refuse to back up
;	backup-limit protected files (BIT 4 of DIR+1), which
;	is documented as "file modified when date not set".
;	When this byte is 1-0FEH, then that's the number of
;	backups remaining.  Normal disks just have a 0 here.
;	Bit 4 of GAT+X'CD' is set when a disk is a protected
;	disk.  This was determined by tracing through the
;	BACKUP/CMD source code.
;
	DB	0		;X'C6' - Backup limit count
;
;
DAYTBL$ DB	'SunMonTueWedThuFriSat'
MONTBL$ DB	'JanFebMarAprMayJunJulAugSepOctNovDec'
;
;	End of low core assignments
;
*GET	IODVR		      ;I/O driver, KEYIN, etc.
*GET	MULDIV		      ;16 bit MULT & DIV
*GET	CLOCKS		      ;Hardware task stuff
@$SYS	EQU	$
	IF	@USA
*GET	KIDVR		      ;Keyboard driver
	ENDIF
	IF	@GERMAN
FREN	EQU	00
GERM	EQU	-1
*GET	KIDVRFG
	ENDIF
	IF	@FRENCH
FREN	EQU	-1
GERM	EQU	00
*GET	KIDVRFG
	ENDIF
*GET	DODVR		      ;Video driver
*GET	PRDVR		      ;Printer driver & filter
*GET	FDCDVR		      ;Floppy disk driver
DVREND$ EQU	$	      ;Start of low I/O area, to 12FFH
	IFGT	$,1200H+START$
	ERR	'Drivers overflow available RAM'
	ENDIF
	ORG	1300H+START$
@BYTEIO EQU	$
	END


