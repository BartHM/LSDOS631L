;LBLIB/ASM - LIB/CLS/FREE/ID commands	TITLE	<LIB - LS-DOS 6.3>;*GET	SVCEQU			; SVC call equates;CR	EQU	13LF	EQU	10;;	We display the LIB commands by looking into SYS1's;	command table.  SYS1 maintains a pointer to this;	for us, stored at 1E02h.  Isn't that nice of it?;OVLAY$	EQU	1E00H		; Where SYS1 starts.;	ORG	2400H;;	LIB command entry point;LIB	JP	JPLIB;;	CLS command entry point;	JP	CLS;;	ID command entry point;	JP	DO_ID;;	TOF command entry point;	LD	C,0CH		; TOF character	LD	A,@PRT		; Do @PRT SVC	RST	28H;M240E	LD	HL,0		; Init to no error	RET	Z		;   and back if okay	LD	L,A		; Move error code to HL	LD	H,0	OR	0C0H		; Abbreviate and return	LD	C,A	LD	A,@ERROR	RST	28H	RET;;	Clear the screen;CLS	LD	A,@CLS		; Gee, this is hard	RST	28H	XOR	A	JR	M240E		; Return without error;;;JPLIB	LD	B,03H		; Init for three librariesLIB0	PUSH	BC	LD	HL,LIBMSG	LD	A,@DSPLY	RST	28H	LD	(HL),LF		; Put LF at start of				;   string for next time	LD	HL,(OVLAY$+2)	; Get table pointer				;   from SYS1LIB1	LD	B,02H		; Display 1st command	CALL	TAB	LD	C,07H		; Init for 7 acrossLIB2	LD	A,(HL)	OR	A	JR	Z,LIB4		; Jump on end	PUSH	HL	LD	DE,7		; Index to lib number	ADD	HL,DELIBX	LD	A,80H		; Init for LIB-A	CP	(HL)		; Is this command in	JR	Z,LIB2A		;   the current library?	POP	AF		; Is not, skip past it	INC	HL	JR	LIB2;LIB2A	POP	HL		; Get 1st char of command	PUSH	BC		; Save reg C	LD	C,(HL)		;   and display in upper	LD	A,@DSP	RST	28H	LD	B,05H		; Write 6-char LIB wordLIB3	INC	HL		; Point to next char	LD	A,(HL)	CP	' '		; if space don't lower	JR	Z,SKPCASE	XOR	20H		; case the charSKPCASE	LD	C,A		; Transfer to C	LD	A,@DSP		;   and display it	RST	28H	DJNZ	LIB3;	LD	B,05H		; Move over 5 spaces	CALL	TAB		;   for start of next command	INC	HL		; Bypass LIB parm vector	INC	HL	INC	HL	POP	BC		; Get across counter	DEC	C		;   and decrement it	JR	NZ,LIB2		; Loop on < 7	LD	C,CR		; Write a new line	LD	A,@DSP	RST	28H	JR	LIB1		; Loop;LIB4	LD	C,CR		; End with new line	LD	A,@DSP	RST	28H	LD	HL,LIBMSG+10	INC	(HL)		; Bump to next lib	LD	A,(LIBX+1)	; Advance RST code also	ADD	A,20H	LD	(LIBX+1),A	POP	BC		; Recover lib count	DJNZ	LIB0		; Loop until all done	LD	HL,0		; set no error	RET;TAB	LD	C,' '		; Display spaces,	LD	A,@DSP	RST	28H	DJNZ	TAB		;  for count in B	RET;LIBMSG	DB	00H	DB	'Library <A>',0DH;	ORG	$<-8+1<+8;DO_ID	LD	HL,IDMSG	LD	A,@DSPLY	RST	28H	LD	HL,0	RETIDMSG	DB	'No service contract!',0DH;	END	LIB