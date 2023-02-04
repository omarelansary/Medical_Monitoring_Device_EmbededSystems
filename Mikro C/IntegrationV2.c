// Interfacing LM35 sensor with PIC16F887 mikroC code
// Internal oscillator used @ 8MHz
// Configuration words: CONFIG1 = 0x2CD4
//                      CONFIG2 = 0x0700


// LCD module connections
 //////////////////////////////////////////////SPI DEF////////////////////////////////
unsigned char LCDpins;
//void LCD_send_string( char *str_ptr );
#define RS  0x04    // RS pin
#define E   0x08    // E pin
//define SET_RS  LCDpins |= RS
//define CLR_RS  LCDpins &= ~RS
//define SET_E   LCDpins |= E
//define CLR_E   LCDpins &= ~E


#define        Scroll_right                0x1e        /* Scroll display one character right (all lines)                 */
#define Scroll_left                        0x18        /* Scroll display one character left (all lines)                        */

#define        LCD_HOME                        0x02        /* Home (move cursor to top/left character position)        */
#define        Cursor_left                        0x10        /* Move cursor one character left                                                                                        */
#define        Cursor_right                0x14        /* Move cursor one character right                                                                                */
#define Cursor_uline                0x0e        /* Turn on visible underline cursor                                                                         */
#define Cursor_block                0x0f        /* Turn on visible blinking-block cursor                                                        */
#define Cursor_invis                0x0c        /* Make cursor invisible                                                                                                                        */
#define        Display_blank                0x08        /* Blank the display (without clearing)                                                                */
#define Display_restore                0x0c        /* Restore the display (with cursor hidden)                                                */
#define        LCD_CLRSCR                        0x01        /* Clear Screen                                                                                                                                                                */

#define        SET_CURSOR                        0x80        /* Set cursor position (Set_cursor+DDRAM address)                        */
#define        Set_CGRAM                                0x40        /* Set pointer in character-generator RAM Set_CGRAM+(CGRAM address)        */


 //////////////////////////////////////////////SPI FUNCTIONS/////////////////////////////////
   void SPI_init()
{

  //master mode, clk fosc/4
  SSPCON.B3=  0;
  SSPCON.B2=  0;
  SSPCON.B1=   0;
  SSPCON.B0=  0;
  SSPCON.SSPEN=1;              // enable synchronous serial port
  // clk idle state low
  SSPCON.CKP=  0;
  // data read on low to high  MODE 0,0
  SSPSTAT.CKE=1; //if ckp=0
  //input data sampled at the middle of interval
   SSPSTAT.SMP=0;
   TRISC.B3 = 0;                 // define clock pin as output
   TRISC.B5=0;                  // define SDO as output (master ) to lcd
   // Define clock pin as an output for clk

}
unsigned char wr_SPI ( unsigned char dat )
{
 SSPBUF = dat;             // write byte to SSPBUF register
 while( !SSPSTAT.BF );  // wait until bus cycle complete
 return ( SSPBUF );         //
}

/* copies LCDpins variable to parallel output of the shift register */
void SPI_to_74HC595(  )
{
    wr_SPI ( LCDpins );     // send LCDpins out the SPI
    PORTE.B0 = 1;                //move data to parallel pins
    PORTE.B0 = 0;
}

 void LCD_sendbyte( unsigned char tosend )
{
    LCDpins &= 0x0f;                //prepare place for the upper nibble
    LCDpins |= ( tosend & 0xf0 );   //copy upper nibble to LCD variable
    LCDpins |= E        ;                  //send
    SPI_to_74HC595();
    LCDpins &= ~E        ;
    SPI_to_74HC595();
    LCDpins &= 0x0f;                    //prepare place for the lower nibble
    LCDpins |= ( tosend << 4 ) & 0xf0;    //copy lower nibble to LCD variable
    LCDpins |= E          ;                   //send
    SPI_to_74HC595();
    LCDpins &= ~E          ;
    SPI_to_74HC595();
}
  void LCD_sendcmd(unsigned char a)
 {   LCDpins &= ~RS         ;
      LCD_sendbyte(a);
  }

void LCD_sendchar(unsigned char a)
{   LCDpins |= RS            ;
    LCD_sendbyte(a);
}
/* LCD initialization by instruction                */
/* 4-bit 2 line                                     */
/* wait times are set for 8MHz clock (TCY 500ns)    */
void LCD_init ( void )
{
  LCDpins &= ~RS              ;
  PORTE.B0 = 0;
  /* wait 100msec */
  Delay_ms(100);
  /* send 0x03 */
  LCDpins =  0x30;  // send 0x3
  LCDpins |= E                 ;
  SPI_to_74HC595 ();
  LCDpins &= ~E                 ;
  SPI_to_74HC595 ();
  /* wait 10ms */
  Delay_ms(10);
  LCDpins |= E  ;        // send 0x3
  SPI_to_74HC595 ();
  LCDpins &= ~E                  ;
  SPI_to_74HC595 ();
  /* wait 10ms */
  Delay_ms(10);
  LCDpins |= E         ;// send 0x3
  SPI_to_74HC595 ();
  LCDpins &= ~E         ;
  SPI_to_74HC595 ();
  /* wait 1ms */
  Delay_ms(10);
  LCDpins =  0x20;        // send 0x2 - switch to 4-bit
  LCDpins |= E           ;
  SPI_to_74HC595();
  LCDpins &= ~E           ;
  SPI_to_74HC595();
  /* regular transfers start here */
 Delay_ms(10);
  LCD_sendcmd ( 0x28 );   //4-bit 2-line 5x7-font
  Delay_ms(10);
  LCD_sendcmd ( 0x01 );   //clear display
  Delay_ms(10);
  LCD_sendcmd ( 0x0c );   //turn off cursor, turn on display
  Delay_ms(10);
  LCD_sendcmd ( 0x06 );   //Increment cursor automatically
}
void LCD_send_string( char *str_ptr )
{
        while (*str_ptr) {
                LCD_sendchar(*str_ptr);
                str_ptr++;
        }
}
void LCD_second_row(  )
{
        LCD_sendcmd( 0xc0 );
}


void LCD_Home(  )
{
//LCD_send_string("                ");
 LCD_sendcmd( LCD_CLRSCR );
 Delay_ms(10);
 LCD_sendcmd( LCD_HOME );
}

// End LCD module connections

char temperature_String[]=" Temp = 00.00 C";
char heartbeat_String[]=" Beat = 00 bpm";
unsigned int Temp;
char txt[15];
unsigned int buttonCounter = 0;     // button Counter
int interruptCounter=0;                  //clock period counter.
int  beatpermin=0;
int  UartCounter=0;
int UartFlag=0;
int OldTemp=0;
int OldBeat=0;
int changedisplayflag=0;
int shutdownflag=0;
////uart
void ser_int();
void tx(char);
void Analog_Init();
void Read_ADC ();
void PORT_Init();
void Change_Display();
void UART_Out_Temperature();
void UART_Out_Heartbeat();
//char rrx();
//void txstr( char *);
void main() {
  PORT_Init();
  ser_int();
  Analog_Init();
  SPI_init();
  LCD_init();

  while(1) {
    Read_ADC();
    //Change_Display();

    if (Oldtemp!=temp){
    OldTemp=temp;
    if (temp > 99)
      temperature_String[7]  = 1 + 48;              // Put 1 (of hundred)

    else
      temperature_String[7]  = ' ';                 // Put space

    temperature_String[8]  = (temp / 10) % 10  + 48;
    temperature_String[9]  =  temp % 10  + 48;
    Change_Display();
    }
    
    if (oldbeat!=beatpermin)
    {
     OldBeat=beatpermin;
     if (beatpermin > 99)
      heartbeat_String[7]  = 1 + 48;              // Put 1 (of hundred)

    else
      heartbeat_String[7]  = ' ';                 // Put space

    heartbeat_String[8]  = (beatpermin / 10) % 10  + 48;
    heartbeat_String[9]  =  beatpermin % 10  + 48;
    Change_Display();
    }
    
    if (changedisplayflag)
    {
     Change_Display();
     changedisplayflag=0;
    }
    
    if(uartflag)
    {
        UartFlag=0;
        if (buttonCounter==0)
        {
         UART_Out_Temperature();
         UART_Out_Heartbeat();
        }
        else if(buttonCounter==1)
        {
         UART_Out_Temperature();
        }
        else if(buttonCounter==2)
        {
         UART_Out_Heartbeat();
        }
    }
    
    if (shutdownflag)
    {
    lCD_Home();
     while(portd.f5==0)
     {
     portd.f0=1;
     //portd.f1=0;            //DigitalGND
     }
     portd.f0=0;

     TMR1H=0;
     TMR1L=0;
     interruptCounter=0;
     beatpermin=0;
    shutdownflag=0;
    Change_Display();
    }
    //portd.f1=portc.f1;      //DigitalGND
    //IntToStr(beatpermin,txt);
    //Lcd_Out(1,1,heartbeat_String);
    //FloatToStr(Temp,txt);

    //tx(temperature_String[0]);                          // Wait 1 second
    //porte=(TMR1H<<8)|(TMR1L);
  }

}
void ser_int()
{
    TXSTA=0x20; //BRGH=0, TXEN = 1, Asynchronous Mode, 8-bit mode
    RCSTA=0b10000000; //Serial Port enabled,8-bit reception
    //SPBRG=12;           //9600 baudrate for 8Mhz =n
    SPBRG=5;
    PIR1.TXIF=0;
    PIR1.RCIF=0;
}

void tx( char a)
{
    TXREG=a;
    while(!PIR1.TXIF);
    PIR1.TXIF = 0;
}



void Analog_Init(){
ADCON0 = 0x80;
ADCON1 = 0x80;
// Select channel 0 = AN0
ADCON0.CHS0 = 0;
ADCON0.CHS1 = 0;
ADCON0.CHS2 = 0;
ADCON0.ADON = 1;      // enable ADC module
}

void Read_ADC (){
ADCON0.GO = 1;       //start conversion
while(ADCON0.GO);
delay_us(100);
//read lower register
//PORTC = ADRESL;
//read higher register
//PORTD = ADRESH;
  Temp=((ADRESH<<8)+ADRESL)*0.488281;


    //temperature_String[12] = 223;                    // Put degree symbol ( � )

    //lcd_out(1, 1, temperature_String);              // Display LM35 temperature result

}

void PORT_Init(){
  OSCCON =  0X60;                  // Set internal oscillator to 4MHz
  ANSEL = 1;                       // Configure RA0 pin as analog (AN0)
  
  TRISA.F1=1;
  TRISC.f6=0;   //Output (TX)
  TRISC.f7=1;   //Input (RX)
  TRISD.F6=1;   //Input change display button
  TRISD.F5=1;   //Input shutdown  button
  TRISD.F0=0;   //output shutdown  button
  //TRISD.F1=0;   //output DigitalGND
  TRISE.F0=0;
  //TRISB.F4=1;
  //PORTB.F4=0;

portd.f0=0;//output shutdown  button
//portd.f1=portc.f1;                  //DigitalGND
TRISC.f1=1;                    // Pulse input
//trisd.b6=0;                  //make the first bit in port c as an output

Tmr0=0x0c;
Tmr1l=0x00;                  //Least Significant Bit
Tmr1h=0x00;                  //Least Significant Bit
T1CON=0b00000011;            //Enable Timer 1 as counter
//T2CON=0b00000100;            //Enable Timer 2 TMR2ON
//PIE1=0b00000010;             //Enable Timer 2 TMR2IE
//PIR1=0b00000010;             //Enable Timer 2 TMR2IF
intcon=0b10100000;           //Enabling tmr0 interrupt.
option_reg=0b00010111;       //Setting of tmr0.
}

void Change_Display()
{
  /*if (PORTD.F6==1){
      if (buttonCounter==0)
      {
       Delay_ms(50);                                     // If button is pressed, delay 0,05s and increment "number" with 1;
       buttonCounter=buttonCounter+1;
       lCD_Home();// Clear display
       //PORTD.F6==1;
      }
      else if(buttonCounter==1)
      {
       Delay_ms(50);                                      // If button is pressed, delay 0,05s and increment "number" with 1;
       buttonCounter=buttonCounter+1;
       lCD_Home();// Clear display
       //PORTD.F6==1;
      }
      else if(buttonCounter==2)
      {
       Delay_ms(50);                                    // If button is pressed, delay 0,05s and increment "number" with 1;
       buttonCounter=0;
       lCD_Home();// Clear display
       //PORTD.F6==1;
      }
    } */
  if (buttonCounter==0)
      {
       lCD_Home();
       delay_ms(10);
       LCD_send_string(temperature_String);// Write Temperature in first row
       LCD_second_row();
       LCD_send_string(heartbeat_String);// Write HeartBeat in second row
      }
      else if(buttonCounter==1)
      {
       //Lcd_Out(1,1,temperature_String);                 // Write Temperature in first row
       lCD_Home();
       delay_ms(10);
       LCD_send_string(temperature_String);// Write Temperature in first row
      }
      else if(buttonCounter==2)
      {
      lCD_Home();
      delay_ms(10);
       LCD_send_string(heartbeat_String);// Write HeartBeat in first row
       //Lcd_Out(1,1,heartbeat_String);                 // Write HeartBeat in second row
      }
}

void interrupt(){
    //if (INTCON.RBIF==1)
    if (PORTD.F6==1)
    {
      delay_ms(50);
      if (buttonCounter==0)
      {
      buttonCounter=buttonCounter+1;
      }
      else if(buttonCounter==1)
      {
       buttonCounter=buttonCounter+1;
      }
      else if(buttonCounter==2)
      {
       buttonCounter=0;
      }
      changedisplayflag=1;
    }

    if (portd.f5==1)
    {
     delay_ms(50);
     shutdownflag=1;
    }
    
   if(intcon.f2=1)          //checking timer0 flag
    {
      intcon.f2=0;          //zeroing the flag again to 0
    }
interruptCounter++;                      //increment the counter for pulse by one
UartCounter++;                           //increment the counter for uart by one
   if(interruptCounter==241)             // 16 for 1 second
    {                       //every 350 cycles make 15 sec.
    beatpermin=(TMR1H<<8)|(TMR1L)*4;
    TMR1H=0;
    TMR1L=0;
    interruptCounter=0;
    }
   if(UartCounter==160)
   {uartflag=1;
   UartCounter=0;}
tmr0=0x0c;                   //initialization the timer again to 4.
}

void UART_Out_Temperature(){
int i;
for (i=1;i<15;i++)
{
tx(temperature_string[i]);
}
tx(13);
}

void UART_Out_Heartbeat(){
int i;
for (i=0;i<14;i++)
{
tx(heartbeat_string[i]);
}
tx(13);
}
// End of code