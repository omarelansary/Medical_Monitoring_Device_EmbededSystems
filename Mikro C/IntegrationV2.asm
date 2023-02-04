
_SPI_init:

;IntegrationV2.c,37 :: 		void SPI_init()
;IntegrationV2.c,41 :: 		SSPCON.B3=  0;
	BCF        SSPCON+0, 3
;IntegrationV2.c,42 :: 		SSPCON.B2=  0;
	BCF        SSPCON+0, 2
;IntegrationV2.c,43 :: 		SSPCON.B1=   0;
	BCF        SSPCON+0, 1
;IntegrationV2.c,44 :: 		SSPCON.B0=  0;
	BCF        SSPCON+0, 0
;IntegrationV2.c,45 :: 		SSPCON.SSPEN=1;              // enable synchronous serial port
	BSF        SSPCON+0, 5
;IntegrationV2.c,47 :: 		SSPCON.CKP=  0;
	BCF        SSPCON+0, 4
;IntegrationV2.c,49 :: 		SSPSTAT.CKE=1; //if ckp=0
	BSF        SSPSTAT+0, 6
;IntegrationV2.c,51 :: 		SSPSTAT.SMP=0;
	BCF        SSPSTAT+0, 7
;IntegrationV2.c,52 :: 		TRISC.B3 = 0;                 // define clock pin as output
	BCF        TRISC+0, 3
;IntegrationV2.c,53 :: 		TRISC.B5=0;                  // define SDO as output (master ) to lcd
	BCF        TRISC+0, 5
;IntegrationV2.c,56 :: 		}
L_end_SPI_init:
	RETURN
; end of _SPI_init

_wr_SPI:

;IntegrationV2.c,57 :: 		unsigned char wr_SPI ( unsigned char dat )
;IntegrationV2.c,59 :: 		SSPBUF = dat;             // write byte to SSPBUF register
	MOVF       FARG_wr_SPI_dat+0, 0
	MOVWF      SSPBUF+0
;IntegrationV2.c,60 :: 		while( !SSPSTAT.BF );  // wait until bus cycle complete
L_wr_SPI0:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_wr_SPI1
	GOTO       L_wr_SPI0
L_wr_SPI1:
;IntegrationV2.c,61 :: 		return ( SSPBUF );         //
	MOVF       SSPBUF+0, 0
	MOVWF      R0+0
;IntegrationV2.c,62 :: 		}
L_end_wr_SPI:
	RETURN
; end of _wr_SPI

_SPI_to_74HC595:

;IntegrationV2.c,65 :: 		void SPI_to_74HC595(  )
;IntegrationV2.c,67 :: 		wr_SPI ( LCDpins );     // send LCDpins out the SPI
	MOVF       _LCDpins+0, 0
	MOVWF      FARG_wr_SPI_dat+0
	CALL       _wr_SPI+0
;IntegrationV2.c,68 :: 		PORTE.B0 = 1;                //move data to parallel pins
	BSF        PORTE+0, 0
;IntegrationV2.c,69 :: 		PORTE.B0 = 0;
	BCF        PORTE+0, 0
;IntegrationV2.c,70 :: 		}
L_end_SPI_to_74HC595:
	RETURN
; end of _SPI_to_74HC595

_LCD_sendbyte:

;IntegrationV2.c,72 :: 		void LCD_sendbyte( unsigned char tosend )
;IntegrationV2.c,74 :: 		LCDpins &= 0x0f;                //prepare place for the upper nibble
	MOVLW      15
	ANDWF      _LCDpins+0, 1
;IntegrationV2.c,75 :: 		LCDpins |= ( tosend & 0xf0 );   //copy upper nibble to LCD variable
	MOVLW      240
	ANDWF      FARG_LCD_sendbyte_tosend+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	IORWF      _LCDpins+0, 1
;IntegrationV2.c,76 :: 		LCDpins |= E        ;                  //send
	BSF        _LCDpins+0, 3
;IntegrationV2.c,77 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,78 :: 		LCDpins &= ~E        ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,79 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,80 :: 		LCDpins &= 0x0f;                    //prepare place for the lower nibble
	MOVLW      15
	ANDWF      _LCDpins+0, 1
;IntegrationV2.c,81 :: 		LCDpins |= ( tosend << 4 ) & 0xf0;    //copy lower nibble to LCD variable
	MOVF       FARG_LCD_sendbyte_tosend+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVLW      240
	ANDWF      R0+0, 1
	MOVF       R0+0, 0
	IORWF      _LCDpins+0, 1
;IntegrationV2.c,82 :: 		LCDpins |= E          ;                   //send
	BSF        _LCDpins+0, 3
;IntegrationV2.c,83 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,84 :: 		LCDpins &= ~E          ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,85 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,86 :: 		}
L_end_LCD_sendbyte:
	RETURN
; end of _LCD_sendbyte

_LCD_sendcmd:

;IntegrationV2.c,87 :: 		void LCD_sendcmd(unsigned char a)
;IntegrationV2.c,88 :: 		{   LCDpins &= ~RS         ;
	BCF        _LCDpins+0, 2
;IntegrationV2.c,89 :: 		LCD_sendbyte(a);
	MOVF       FARG_LCD_sendcmd_a+0, 0
	MOVWF      FARG_LCD_sendbyte_tosend+0
	CALL       _LCD_sendbyte+0
;IntegrationV2.c,90 :: 		}
L_end_LCD_sendcmd:
	RETURN
; end of _LCD_sendcmd

_LCD_sendchar:

;IntegrationV2.c,92 :: 		void LCD_sendchar(unsigned char a)
;IntegrationV2.c,93 :: 		{   LCDpins |= RS            ;
	BSF        _LCDpins+0, 2
;IntegrationV2.c,94 :: 		LCD_sendbyte(a);
	MOVF       FARG_LCD_sendchar_a+0, 0
	MOVWF      FARG_LCD_sendbyte_tosend+0
	CALL       _LCD_sendbyte+0
;IntegrationV2.c,95 :: 		}
L_end_LCD_sendchar:
	RETURN
; end of _LCD_sendchar

_LCD_init:

;IntegrationV2.c,99 :: 		void LCD_init ( void )
;IntegrationV2.c,101 :: 		LCDpins &= ~RS              ;
	BCF        _LCDpins+0, 2
;IntegrationV2.c,102 :: 		PORTE.B0 = 0;
	BCF        PORTE+0, 0
;IntegrationV2.c,104 :: 		Delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_LCD_init2:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init2
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init2
	NOP
	NOP
;IntegrationV2.c,106 :: 		LCDpins =  0x30;  // send 0x3
	MOVLW      48
	MOVWF      _LCDpins+0
;IntegrationV2.c,107 :: 		LCDpins |= E                 ;
	MOVLW      56
	MOVWF      _LCDpins+0
;IntegrationV2.c,108 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,109 :: 		LCDpins &= ~E                 ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,110 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,112 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init3:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init3
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init3
	NOP
	NOP
;IntegrationV2.c,113 :: 		LCDpins |= E  ;        // send 0x3
	BSF        _LCDpins+0, 3
;IntegrationV2.c,114 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,115 :: 		LCDpins &= ~E                  ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,116 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,118 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init4:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init4
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init4
	NOP
	NOP
;IntegrationV2.c,119 :: 		LCDpins |= E         ;// send 0x3
	BSF        _LCDpins+0, 3
;IntegrationV2.c,120 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,121 :: 		LCDpins &= ~E         ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,122 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,124 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init5:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init5
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init5
	NOP
	NOP
;IntegrationV2.c,125 :: 		LCDpins =  0x20;        // send 0x2 - switch to 4-bit
	MOVLW      32
	MOVWF      _LCDpins+0
;IntegrationV2.c,126 :: 		LCDpins |= E           ;
	MOVLW      40
	MOVWF      _LCDpins+0
;IntegrationV2.c,127 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,128 :: 		LCDpins &= ~E           ;
	BCF        _LCDpins+0, 3
;IntegrationV2.c,129 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;IntegrationV2.c,131 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init6:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init6
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init6
	NOP
	NOP
;IntegrationV2.c,132 :: 		LCD_sendcmd ( 0x28 );   //4-bit 2-line 5x7-font
	MOVLW      40
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,133 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init7:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init7
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init7
	NOP
	NOP
;IntegrationV2.c,134 :: 		LCD_sendcmd ( 0x01 );   //clear display
	MOVLW      1
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,135 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init8:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init8
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init8
	NOP
	NOP
;IntegrationV2.c,136 :: 		LCD_sendcmd ( 0x0c );   //turn off cursor, turn on display
	MOVLW      12
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,137 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init9:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init9
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init9
	NOP
	NOP
;IntegrationV2.c,138 :: 		LCD_sendcmd ( 0x06 );   //Increment cursor automatically
	MOVLW      6
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,139 :: 		}
L_end_LCD_init:
	RETURN
; end of _LCD_init

_LCD_send_string:

;IntegrationV2.c,140 :: 		void LCD_send_string( char *str_ptr )
;IntegrationV2.c,142 :: 		while (*str_ptr) {
L_LCD_send_string10:
	MOVF       FARG_LCD_send_string_str_ptr+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_send_string11
;IntegrationV2.c,143 :: 		LCD_sendchar(*str_ptr);
	MOVF       FARG_LCD_send_string_str_ptr+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_LCD_sendchar_a+0
	CALL       _LCD_sendchar+0
;IntegrationV2.c,144 :: 		str_ptr++;
	INCF       FARG_LCD_send_string_str_ptr+0, 1
;IntegrationV2.c,145 :: 		}
	GOTO       L_LCD_send_string10
L_LCD_send_string11:
;IntegrationV2.c,146 :: 		}
L_end_LCD_send_string:
	RETURN
; end of _LCD_send_string

_LCD_second_row:

;IntegrationV2.c,147 :: 		void LCD_second_row(  )
;IntegrationV2.c,149 :: 		LCD_sendcmd( 0xc0 );
	MOVLW      192
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,150 :: 		}
L_end_LCD_second_row:
	RETURN
; end of _LCD_second_row

_LCD_Home:

;IntegrationV2.c,153 :: 		void LCD_Home(  )
;IntegrationV2.c,156 :: 		LCD_sendcmd( LCD_CLRSCR );
	MOVLW      1
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,157 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_Home12:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Home12
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Home12
	NOP
	NOP
;IntegrationV2.c,158 :: 		LCD_sendcmd( LCD_HOME );
	MOVLW      2
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;IntegrationV2.c,159 :: 		}
L_end_LCD_Home:
	RETURN
; end of _LCD_Home

_main:

;IntegrationV2.c,187 :: 		void main() {
;IntegrationV2.c,188 :: 		PORT_Init();
	CALL       _PORT_Init+0
;IntegrationV2.c,189 :: 		ser_int();
	CALL       _ser_int+0
;IntegrationV2.c,190 :: 		Analog_Init();
	CALL       _Analog_Init+0
;IntegrationV2.c,191 :: 		SPI_init();
	CALL       _SPI_init+0
;IntegrationV2.c,192 :: 		LCD_init();
	CALL       _LCD_init+0
;IntegrationV2.c,194 :: 		while(1) {
L_main13:
;IntegrationV2.c,195 :: 		Read_ADC();
	CALL       _Read_ADC+0
;IntegrationV2.c,198 :: 		if (Oldtemp!=temp){
	MOVF       _OldTemp+1, 0
	XORWF      _Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main73
	MOVF       _Temp+0, 0
	XORWF      _OldTemp+0, 0
L__main73:
	BTFSC      STATUS+0, 2
	GOTO       L_main15
;IntegrationV2.c,199 :: 		OldTemp=temp;
	MOVF       _Temp+0, 0
	MOVWF      _OldTemp+0
	MOVF       _Temp+1, 0
	MOVWF      _OldTemp+1
;IntegrationV2.c,200 :: 		if (temp > 99)
	MOVF       _Temp+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main74
	MOVF       _Temp+0, 0
	SUBLW      99
L__main74:
	BTFSC      STATUS+0, 0
	GOTO       L_main16
;IntegrationV2.c,201 :: 		temperature_String[7]  = 1 + 48;              // Put 1 (of hundred)
	MOVLW      49
	MOVWF      _temperature_String+7
	GOTO       L_main17
L_main16:
;IntegrationV2.c,204 :: 		temperature_String[7]  = ' ';                 // Put space
	MOVLW      32
	MOVWF      _temperature_String+7
L_main17:
;IntegrationV2.c,206 :: 		temperature_String[8]  = (temp / 10) % 10  + 48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _Temp+0, 0
	MOVWF      R0+0
	MOVF       _Temp+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _temperature_String+8
;IntegrationV2.c,207 :: 		temperature_String[9]  =  temp % 10  + 48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _Temp+0, 0
	MOVWF      R0+0
	MOVF       _Temp+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _temperature_String+9
;IntegrationV2.c,208 :: 		Change_Display();
	CALL       _Change_Display+0
;IntegrationV2.c,209 :: 		}
L_main15:
;IntegrationV2.c,211 :: 		if (oldbeat!=beatpermin)
	MOVF       _OldBeat+1, 0
	XORWF      _beatpermin+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main75
	MOVF       _beatpermin+0, 0
	XORWF      _OldBeat+0, 0
L__main75:
	BTFSC      STATUS+0, 2
	GOTO       L_main18
;IntegrationV2.c,213 :: 		OldBeat=beatpermin;
	MOVF       _beatpermin+0, 0
	MOVWF      _OldBeat+0
	MOVF       _beatpermin+1, 0
	MOVWF      _OldBeat+1
;IntegrationV2.c,214 :: 		if (beatpermin > 99)
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      _beatpermin+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main76
	MOVF       _beatpermin+0, 0
	SUBLW      99
L__main76:
	BTFSC      STATUS+0, 0
	GOTO       L_main19
;IntegrationV2.c,215 :: 		heartbeat_String[7]  = 1 + 48;              // Put 1 (of hundred)
	MOVLW      49
	MOVWF      _heartbeat_String+7
	GOTO       L_main20
L_main19:
;IntegrationV2.c,218 :: 		heartbeat_String[7]  = ' ';                 // Put space
	MOVLW      32
	MOVWF      _heartbeat_String+7
L_main20:
;IntegrationV2.c,220 :: 		heartbeat_String[8]  = (beatpermin / 10) % 10  + 48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _beatpermin+0, 0
	MOVWF      R0+0
	MOVF       _beatpermin+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _heartbeat_String+8
;IntegrationV2.c,221 :: 		heartbeat_String[9]  =  beatpermin % 10  + 48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _beatpermin+0, 0
	MOVWF      R0+0
	MOVF       _beatpermin+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _heartbeat_String+9
;IntegrationV2.c,222 :: 		Change_Display();
	CALL       _Change_Display+0
;IntegrationV2.c,223 :: 		}
L_main18:
;IntegrationV2.c,225 :: 		if (changedisplayflag)
	MOVF       _changedisplayflag+0, 0
	IORWF      _changedisplayflag+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main21
;IntegrationV2.c,227 :: 		Change_Display();
	CALL       _Change_Display+0
;IntegrationV2.c,228 :: 		changedisplayflag=0;
	CLRF       _changedisplayflag+0
	CLRF       _changedisplayflag+1
;IntegrationV2.c,229 :: 		}
L_main21:
;IntegrationV2.c,231 :: 		if(uartflag)
	MOVF       _UartFlag+0, 0
	IORWF      _UartFlag+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main22
;IntegrationV2.c,233 :: 		UartFlag=0;
	CLRF       _UartFlag+0
	CLRF       _UartFlag+1
;IntegrationV2.c,234 :: 		if (buttonCounter==0)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main77
	MOVLW      0
	XORWF      _buttonCounter+0, 0
L__main77:
	BTFSS      STATUS+0, 2
	GOTO       L_main23
;IntegrationV2.c,236 :: 		UART_Out_Temperature();
	CALL       _UART_Out_Temperature+0
;IntegrationV2.c,237 :: 		UART_Out_Heartbeat();
	CALL       _UART_Out_Heartbeat+0
;IntegrationV2.c,238 :: 		}
	GOTO       L_main24
L_main23:
;IntegrationV2.c,239 :: 		else if(buttonCounter==1)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      1
	XORWF      _buttonCounter+0, 0
L__main78:
	BTFSS      STATUS+0, 2
	GOTO       L_main25
;IntegrationV2.c,241 :: 		UART_Out_Temperature();
	CALL       _UART_Out_Temperature+0
;IntegrationV2.c,242 :: 		}
	GOTO       L_main26
L_main25:
;IntegrationV2.c,243 :: 		else if(buttonCounter==2)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      2
	XORWF      _buttonCounter+0, 0
L__main79:
	BTFSS      STATUS+0, 2
	GOTO       L_main27
;IntegrationV2.c,245 :: 		UART_Out_Heartbeat();
	CALL       _UART_Out_Heartbeat+0
;IntegrationV2.c,246 :: 		}
L_main27:
L_main26:
L_main24:
;IntegrationV2.c,247 :: 		}
L_main22:
;IntegrationV2.c,249 :: 		if (shutdownflag)
	MOVF       _shutdownflag+0, 0
	IORWF      _shutdownflag+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main28
;IntegrationV2.c,251 :: 		lCD_Home();
	CALL       _LCD_Home+0
;IntegrationV2.c,252 :: 		while(portd.f5==0)
L_main29:
	BTFSC      PORTD+0, 5
	GOTO       L_main30
;IntegrationV2.c,254 :: 		portd.f0=1;
	BSF        PORTD+0, 0
;IntegrationV2.c,256 :: 		}
	GOTO       L_main29
L_main30:
;IntegrationV2.c,257 :: 		portd.f0=0;
	BCF        PORTD+0, 0
;IntegrationV2.c,259 :: 		TMR1H=0;
	CLRF       TMR1H+0
;IntegrationV2.c,260 :: 		TMR1L=0;
	CLRF       TMR1L+0
;IntegrationV2.c,261 :: 		interruptCounter=0;
	CLRF       _interruptCounter+0
	CLRF       _interruptCounter+1
;IntegrationV2.c,262 :: 		beatpermin=0;
	CLRF       _beatpermin+0
	CLRF       _beatpermin+1
;IntegrationV2.c,263 :: 		shutdownflag=0;
	CLRF       _shutdownflag+0
	CLRF       _shutdownflag+1
;IntegrationV2.c,264 :: 		Change_Display();
	CALL       _Change_Display+0
;IntegrationV2.c,265 :: 		}
L_main28:
;IntegrationV2.c,273 :: 		}
	GOTO       L_main13
;IntegrationV2.c,275 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ser_int:

;IntegrationV2.c,276 :: 		void ser_int()
;IntegrationV2.c,278 :: 		TXSTA=0x20; //BRGH=0, TXEN = 1, Asynchronous Mode, 8-bit mode
	MOVLW      32
	MOVWF      TXSTA+0
;IntegrationV2.c,279 :: 		RCSTA=0b10000000; //Serial Port enabled,8-bit reception
	MOVLW      128
	MOVWF      RCSTA+0
;IntegrationV2.c,281 :: 		SPBRG=5;
	MOVLW      5
	MOVWF      SPBRG+0
;IntegrationV2.c,282 :: 		PIR1.TXIF=0;
	BCF        PIR1+0, 4
;IntegrationV2.c,283 :: 		PIR1.RCIF=0;
	BCF        PIR1+0, 5
;IntegrationV2.c,284 :: 		}
L_end_ser_int:
	RETURN
; end of _ser_int

_tx:

;IntegrationV2.c,286 :: 		void tx( char a)
;IntegrationV2.c,288 :: 		TXREG=a;
	MOVF       FARG_tx_a+0, 0
	MOVWF      TXREG+0
;IntegrationV2.c,289 :: 		while(!PIR1.TXIF);
L_tx31:
	BTFSC      PIR1+0, 4
	GOTO       L_tx32
	GOTO       L_tx31
L_tx32:
;IntegrationV2.c,290 :: 		PIR1.TXIF = 0;
	BCF        PIR1+0, 4
;IntegrationV2.c,291 :: 		}
L_end_tx:
	RETURN
; end of _tx

_Analog_Init:

;IntegrationV2.c,295 :: 		void Analog_Init(){
;IntegrationV2.c,296 :: 		ADCON0 = 0x80;
	MOVLW      128
	MOVWF      ADCON0+0
;IntegrationV2.c,297 :: 		ADCON1 = 0x80;
	MOVLW      128
	MOVWF      ADCON1+0
;IntegrationV2.c,299 :: 		ADCON0.CHS0 = 0;
	BCF        ADCON0+0, 2
;IntegrationV2.c,300 :: 		ADCON0.CHS1 = 0;
	BCF        ADCON0+0, 3
;IntegrationV2.c,301 :: 		ADCON0.CHS2 = 0;
	BCF        ADCON0+0, 4
;IntegrationV2.c,302 :: 		ADCON0.ADON = 1;      // enable ADC module
	BSF        ADCON0+0, 0
;IntegrationV2.c,303 :: 		}
L_end_Analog_Init:
	RETURN
; end of _Analog_Init

_Read_ADC:

;IntegrationV2.c,305 :: 		void Read_ADC (){
;IntegrationV2.c,306 :: 		ADCON0.GO = 1;       //start conversion
	BSF        ADCON0+0, 1
;IntegrationV2.c,307 :: 		while(ADCON0.GO);
L_Read_ADC33:
	BTFSS      ADCON0+0, 1
	GOTO       L_Read_ADC34
	GOTO       L_Read_ADC33
L_Read_ADC34:
;IntegrationV2.c,308 :: 		delay_us(100);
	MOVLW      33
	MOVWF      R13+0
L_Read_ADC35:
	DECFSZ     R13+0, 1
	GOTO       L_Read_ADC35
;IntegrationV2.c,313 :: 		Temp=((ADRESH<<8)+ADRESL)*0.488281;
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	ADDWF      R0+0, 1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	CALL       _word2double+0
	MOVLW      248
	MOVWF      R4+0
	MOVLW      255
	MOVWF      R4+1
	MOVLW      121
	MOVWF      R4+2
	MOVLW      125
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	CALL       _double2word+0
	MOVF       R0+0, 0
	MOVWF      _Temp+0
	MOVF       R0+1, 0
	MOVWF      _Temp+1
;IntegrationV2.c,320 :: 		}
L_end_Read_ADC:
	RETURN
; end of _Read_ADC

_PORT_Init:

;IntegrationV2.c,322 :: 		void PORT_Init(){
;IntegrationV2.c,323 :: 		OSCCON =  0X60;                  // Set internal oscillator to 4MHz
	MOVLW      96
	MOVWF      OSCCON+0
;IntegrationV2.c,324 :: 		ANSEL = 1;                       // Configure RA0 pin as analog (AN0)
	MOVLW      1
	MOVWF      ANSEL+0
;IntegrationV2.c,326 :: 		TRISA.F1=1;
	BSF        TRISA+0, 1
;IntegrationV2.c,327 :: 		TRISC.f6=0;   //Output (TX)
	BCF        TRISC+0, 6
;IntegrationV2.c,328 :: 		TRISC.f7=1;   //Input (RX)
	BSF        TRISC+0, 7
;IntegrationV2.c,329 :: 		TRISD.F6=1;   //Input change display button
	BSF        TRISD+0, 6
;IntegrationV2.c,330 :: 		TRISD.F5=1;   //Input shutdown  button
	BSF        TRISD+0, 5
;IntegrationV2.c,331 :: 		TRISD.F0=0;   //output shutdown  button
	BCF        TRISD+0, 0
;IntegrationV2.c,333 :: 		TRISE.F0=0;
	BCF        TRISE+0, 0
;IntegrationV2.c,337 :: 		portd.f0=0;//output shutdown  button
	BCF        PORTD+0, 0
;IntegrationV2.c,339 :: 		TRISC.f1=1;                    // Pulse input
	BSF        TRISC+0, 1
;IntegrationV2.c,342 :: 		Tmr0=0x0c;
	MOVLW      12
	MOVWF      TMR0+0
;IntegrationV2.c,343 :: 		Tmr1l=0x00;                  //Least Significant Bit
	CLRF       TMR1L+0
;IntegrationV2.c,344 :: 		Tmr1h=0x00;                  //Least Significant Bit
	CLRF       TMR1H+0
;IntegrationV2.c,345 :: 		T1CON=0b00000011;            //Enable Timer 1 as counter
	MOVLW      3
	MOVWF      T1CON+0
;IntegrationV2.c,349 :: 		intcon=0b10100000;           //Enabling tmr0 interrupt.
	MOVLW      160
	MOVWF      INTCON+0
;IntegrationV2.c,350 :: 		option_reg=0b00010111;       //Setting of tmr0.
	MOVLW      23
	MOVWF      OPTION_REG+0
;IntegrationV2.c,351 :: 		}
L_end_PORT_Init:
	RETURN
; end of _PORT_Init

_Change_Display:

;IntegrationV2.c,353 :: 		void Change_Display()
;IntegrationV2.c,378 :: 		if (buttonCounter==0)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Change_Display86
	MOVLW      0
	XORWF      _buttonCounter+0, 0
L__Change_Display86:
	BTFSS      STATUS+0, 2
	GOTO       L_Change_Display36
;IntegrationV2.c,380 :: 		lCD_Home();
	CALL       _LCD_Home+0
;IntegrationV2.c,381 :: 		delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_Change_Display37:
	DECFSZ     R13+0, 1
	GOTO       L_Change_Display37
	DECFSZ     R12+0, 1
	GOTO       L_Change_Display37
	NOP
	NOP
;IntegrationV2.c,382 :: 		LCD_send_string(temperature_String);// Write Temperature in first row
	MOVLW      _temperature_String+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;IntegrationV2.c,383 :: 		LCD_second_row();
	CALL       _LCD_second_row+0
;IntegrationV2.c,384 :: 		LCD_send_string(heartbeat_String);// Write HeartBeat in second row
	MOVLW      _heartbeat_String+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;IntegrationV2.c,385 :: 		}
	GOTO       L_Change_Display38
L_Change_Display36:
;IntegrationV2.c,386 :: 		else if(buttonCounter==1)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Change_Display87
	MOVLW      1
	XORWF      _buttonCounter+0, 0
L__Change_Display87:
	BTFSS      STATUS+0, 2
	GOTO       L_Change_Display39
;IntegrationV2.c,389 :: 		lCD_Home();
	CALL       _LCD_Home+0
;IntegrationV2.c,390 :: 		delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_Change_Display40:
	DECFSZ     R13+0, 1
	GOTO       L_Change_Display40
	DECFSZ     R12+0, 1
	GOTO       L_Change_Display40
	NOP
	NOP
;IntegrationV2.c,391 :: 		LCD_send_string(temperature_String);// Write Temperature in first row
	MOVLW      _temperature_String+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;IntegrationV2.c,392 :: 		}
	GOTO       L_Change_Display41
L_Change_Display39:
;IntegrationV2.c,393 :: 		else if(buttonCounter==2)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Change_Display88
	MOVLW      2
	XORWF      _buttonCounter+0, 0
L__Change_Display88:
	BTFSS      STATUS+0, 2
	GOTO       L_Change_Display42
;IntegrationV2.c,395 :: 		lCD_Home();
	CALL       _LCD_Home+0
;IntegrationV2.c,396 :: 		delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_Change_Display43:
	DECFSZ     R13+0, 1
	GOTO       L_Change_Display43
	DECFSZ     R12+0, 1
	GOTO       L_Change_Display43
	NOP
	NOP
;IntegrationV2.c,397 :: 		LCD_send_string(heartbeat_String);// Write HeartBeat in first row
	MOVLW      _heartbeat_String+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;IntegrationV2.c,399 :: 		}
L_Change_Display42:
L_Change_Display41:
L_Change_Display38:
;IntegrationV2.c,400 :: 		}
L_end_Change_Display:
	RETURN
; end of _Change_Display

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;IntegrationV2.c,402 :: 		void interrupt(){
;IntegrationV2.c,404 :: 		if (PORTD.F6==1)
	BTFSS      PORTD+0, 6
	GOTO       L_interrupt44
;IntegrationV2.c,406 :: 		delay_ms(50);
	MOVLW      65
	MOVWF      R12+0
	MOVLW      238
	MOVWF      R13+0
L_interrupt45:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt45
	DECFSZ     R12+0, 1
	GOTO       L_interrupt45
	NOP
;IntegrationV2.c,407 :: 		if (buttonCounter==0)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt91
	MOVLW      0
	XORWF      _buttonCounter+0, 0
L__interrupt91:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt46
;IntegrationV2.c,409 :: 		buttonCounter=buttonCounter+1;
	INCF       _buttonCounter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _buttonCounter+1, 1
;IntegrationV2.c,410 :: 		}
	GOTO       L_interrupt47
L_interrupt46:
;IntegrationV2.c,411 :: 		else if(buttonCounter==1)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt92
	MOVLW      1
	XORWF      _buttonCounter+0, 0
L__interrupt92:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt48
;IntegrationV2.c,413 :: 		buttonCounter=buttonCounter+1;
	INCF       _buttonCounter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _buttonCounter+1, 1
;IntegrationV2.c,414 :: 		}
	GOTO       L_interrupt49
L_interrupt48:
;IntegrationV2.c,415 :: 		else if(buttonCounter==2)
	MOVLW      0
	XORWF      _buttonCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt93
	MOVLW      2
	XORWF      _buttonCounter+0, 0
L__interrupt93:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt50
;IntegrationV2.c,417 :: 		buttonCounter=0;
	CLRF       _buttonCounter+0
	CLRF       _buttonCounter+1
;IntegrationV2.c,418 :: 		}
L_interrupt50:
L_interrupt49:
L_interrupt47:
;IntegrationV2.c,419 :: 		changedisplayflag=1;
	MOVLW      1
	MOVWF      _changedisplayflag+0
	MOVLW      0
	MOVWF      _changedisplayflag+1
;IntegrationV2.c,420 :: 		}
L_interrupt44:
;IntegrationV2.c,422 :: 		if (portd.f5==1)
	BTFSS      PORTD+0, 5
	GOTO       L_interrupt51
;IntegrationV2.c,424 :: 		delay_ms(50);
	MOVLW      65
	MOVWF      R12+0
	MOVLW      238
	MOVWF      R13+0
L_interrupt52:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt52
	DECFSZ     R12+0, 1
	GOTO       L_interrupt52
	NOP
;IntegrationV2.c,425 :: 		shutdownflag=1;
	MOVLW      1
	MOVWF      _shutdownflag+0
	MOVLW      0
	MOVWF      _shutdownflag+1
;IntegrationV2.c,426 :: 		}
L_interrupt51:
;IntegrationV2.c,428 :: 		if(intcon.f2=1)          //checking timer0 flag
	BSF        INTCON+0, 2
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt53
;IntegrationV2.c,430 :: 		intcon.f2=0;          //zeroing the flag again to 0
	BCF        INTCON+0, 2
;IntegrationV2.c,431 :: 		}
L_interrupt53:
;IntegrationV2.c,432 :: 		interruptCounter++;                      //increment the counter for pulse by one
	INCF       _interruptCounter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _interruptCounter+1, 1
;IntegrationV2.c,433 :: 		UartCounter++;                           //increment the counter for uart by one
	INCF       _UartCounter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _UartCounter+1, 1
;IntegrationV2.c,434 :: 		if(interruptCounter==241)             // 16 for 1 second
	MOVLW      0
	XORWF      _interruptCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt94
	MOVLW      241
	XORWF      _interruptCounter+0, 0
L__interrupt94:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt54
;IntegrationV2.c,436 :: 		beatpermin=(TMR1H<<8)|(TMR1L)*4;
	MOVF       TMR1H+0, 0
	MOVWF      _beatpermin+1
	CLRF       _beatpermin+0
	MOVF       TMR1L+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      _beatpermin+0, 1
	MOVF       R0+1, 0
	IORWF      _beatpermin+1, 1
;IntegrationV2.c,437 :: 		TMR1H=0;
	CLRF       TMR1H+0
;IntegrationV2.c,438 :: 		TMR1L=0;
	CLRF       TMR1L+0
;IntegrationV2.c,439 :: 		interruptCounter=0;
	CLRF       _interruptCounter+0
	CLRF       _interruptCounter+1
;IntegrationV2.c,440 :: 		}
L_interrupt54:
;IntegrationV2.c,441 :: 		if(UartCounter==160)
	MOVLW      0
	XORWF      _UartCounter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt95
	MOVLW      160
	XORWF      _UartCounter+0, 0
L__interrupt95:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt55
;IntegrationV2.c,442 :: 		{uartflag=1;
	MOVLW      1
	MOVWF      _UartFlag+0
	MOVLW      0
	MOVWF      _UartFlag+1
;IntegrationV2.c,443 :: 		UartCounter=0;}
	CLRF       _UartCounter+0
	CLRF       _UartCounter+1
L_interrupt55:
;IntegrationV2.c,444 :: 		tmr0=0x0c;                   //initialization the timer again to 4.
	MOVLW      12
	MOVWF      TMR0+0
;IntegrationV2.c,445 :: 		}
L_end_interrupt:
L__interrupt90:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_UART_Out_Temperature:

;IntegrationV2.c,447 :: 		void UART_Out_Temperature(){
;IntegrationV2.c,449 :: 		for (i=1;i<15;i++)
	MOVLW      1
	MOVWF      UART_Out_Temperature_i_L0+0
	MOVLW      0
	MOVWF      UART_Out_Temperature_i_L0+1
L_UART_Out_Temperature56:
	MOVLW      128
	XORWF      UART_Out_Temperature_i_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_Out_Temperature97
	MOVLW      15
	SUBWF      UART_Out_Temperature_i_L0+0, 0
L__UART_Out_Temperature97:
	BTFSC      STATUS+0, 0
	GOTO       L_UART_Out_Temperature57
;IntegrationV2.c,451 :: 		tx(temperature_string[i]);
	MOVF       UART_Out_Temperature_i_L0+0, 0
	ADDLW      _temperature_String+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;IntegrationV2.c,449 :: 		for (i=1;i<15;i++)
	INCF       UART_Out_Temperature_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       UART_Out_Temperature_i_L0+1, 1
;IntegrationV2.c,452 :: 		}
	GOTO       L_UART_Out_Temperature56
L_UART_Out_Temperature57:
;IntegrationV2.c,453 :: 		tx(13);
	MOVLW      13
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;IntegrationV2.c,454 :: 		}
L_end_UART_Out_Temperature:
	RETURN
; end of _UART_Out_Temperature

_UART_Out_Heartbeat:

;IntegrationV2.c,456 :: 		void UART_Out_Heartbeat(){
;IntegrationV2.c,458 :: 		for (i=0;i<14;i++)
	CLRF       UART_Out_Heartbeat_i_L0+0
	CLRF       UART_Out_Heartbeat_i_L0+1
L_UART_Out_Heartbeat59:
	MOVLW      128
	XORWF      UART_Out_Heartbeat_i_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_Out_Heartbeat99
	MOVLW      14
	SUBWF      UART_Out_Heartbeat_i_L0+0, 0
L__UART_Out_Heartbeat99:
	BTFSC      STATUS+0, 0
	GOTO       L_UART_Out_Heartbeat60
;IntegrationV2.c,460 :: 		tx(heartbeat_string[i]);
	MOVF       UART_Out_Heartbeat_i_L0+0, 0
	ADDLW      _heartbeat_String+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;IntegrationV2.c,458 :: 		for (i=0;i<14;i++)
	INCF       UART_Out_Heartbeat_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       UART_Out_Heartbeat_i_L0+1, 1
;IntegrationV2.c,461 :: 		}
	GOTO       L_UART_Out_Heartbeat59
L_UART_Out_Heartbeat60:
;IntegrationV2.c,462 :: 		tx(13);
	MOVLW      13
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;IntegrationV2.c,463 :: 		}
L_end_UART_Out_Heartbeat:
	RETURN
; end of _UART_Out_Heartbeat
