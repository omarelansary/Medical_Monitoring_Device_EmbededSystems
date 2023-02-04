#line 1 "C:/My Data/College Courses/5_Fifth HEM term Fall 2022/Embeded Systems/Final Project/Integration V2/Mikro C/IntegrationV2.c"








unsigned char LCDpins;
#line 37 "C:/My Data/College Courses/5_Fifth HEM term Fall 2022/Embeded Systems/Final Project/Integration V2/Mikro C/IntegrationV2.c"
 void SPI_init()
{


 SSPCON.B3= 0;
 SSPCON.B2= 0;
 SSPCON.B1= 0;
 SSPCON.B0= 0;
 SSPCON.SSPEN=1;

 SSPCON.CKP= 0;

 SSPSTAT.CKE=1;

 SSPSTAT.SMP=0;
 TRISC.B3 = 0;
 TRISC.B5=0;


}
unsigned char wr_SPI ( unsigned char dat )
{
 SSPBUF = dat;
 while( !SSPSTAT.BF );
 return ( SSPBUF );
}


void SPI_to_74HC595( )
{
 wr_SPI ( LCDpins );
 PORTE.B0 = 1;
 PORTE.B0 = 0;
}

 void LCD_sendbyte( unsigned char tosend )
{
 LCDpins &= 0x0f;
 LCDpins |= ( tosend & 0xf0 );
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();
 LCDpins &= 0x0f;
 LCDpins |= ( tosend << 4 ) & 0xf0;
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();
}
 void LCD_sendcmd(unsigned char a)
 { LCDpins &= ~ 0x04  ;
 LCD_sendbyte(a);
 }

void LCD_sendchar(unsigned char a)
{ LCDpins |=  0x04  ;
 LCD_sendbyte(a);
}



void LCD_init ( void )
{
 LCDpins &= ~ 0x04  ;
 PORTE.B0 = 0;

 Delay_ms(100);

 LCDpins = 0x30;
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins = 0x20;
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();

 Delay_ms(10);
 LCD_sendcmd ( 0x28 );
 Delay_ms(10);
 LCD_sendcmd ( 0x01 );
 Delay_ms(10);
 LCD_sendcmd ( 0x0c );
 Delay_ms(10);
 LCD_sendcmd ( 0x06 );
}
void LCD_send_string( char *str_ptr )
{
 while (*str_ptr) {
 LCD_sendchar(*str_ptr);
 str_ptr++;
 }
}
void LCD_second_row( )
{
 LCD_sendcmd( 0xc0 );
}


void LCD_Home( )
{

 LCD_sendcmd(  0x01  );
 Delay_ms(10);
 LCD_sendcmd(  0x02  );
}



char temperature_String[]=" Temp = 00.00 C";
char heartbeat_String[]=" Beat = 00 bpm";
unsigned int Temp;
char txt[15];
unsigned int buttonCounter = 0;
int interruptCounter=0;
int beatpermin=0;
int UartCounter=0;
int UartFlag=0;
int OldTemp=0;
int OldBeat=0;
int changedisplayflag=0;
int shutdownflag=0;

void ser_int();
void tx(char);
void Analog_Init();
void Read_ADC ();
void PORT_Init();
void Change_Display();
void UART_Out_Temperature();
void UART_Out_Heartbeat();


void main() {
 PORT_Init();
 ser_int();
 Analog_Init();
 SPI_init();
 LCD_init();

 while(1) {
 Read_ADC();


 if (Oldtemp!=temp){
 OldTemp=temp;
 if (temp > 99)
 temperature_String[7] = 1 + 48;

 else
 temperature_String[7] = ' ';

 temperature_String[8] = (temp / 10) % 10 + 48;
 temperature_String[9] = temp % 10 + 48;
 Change_Display();
 }

 if (oldbeat!=beatpermin)
 {
 OldBeat=beatpermin;
 if (beatpermin > 99)
 heartbeat_String[7] = 1 + 48;

 else
 heartbeat_String[7] = ' ';

 heartbeat_String[8] = (beatpermin / 10) % 10 + 48;
 heartbeat_String[9] = beatpermin % 10 + 48;
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

 }
 portd.f0=0;

 TMR1H=0;
 TMR1L=0;
 interruptCounter=0;
 beatpermin=0;
 shutdownflag=0;
 Change_Display();
 }







 }

}
void ser_int()
{
 TXSTA=0x20;
 RCSTA=0b10000000;

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

ADCON0.CHS0 = 0;
ADCON0.CHS1 = 0;
ADCON0.CHS2 = 0;
ADCON0.ADON = 1;
}

void Read_ADC (){
ADCON0.GO = 1;
while(ADCON0.GO);
delay_us(100);




 Temp=((ADRESH<<8)+ADRESL)*0.488281;






}

void PORT_Init(){
 OSCCON = 0X60;
 ANSEL = 1;

 TRISA.F1=1;
 TRISC.f6=0;
 TRISC.f7=1;
 TRISD.F6=1;
 TRISD.F5=1;
 TRISD.F0=0;

 TRISE.F0=0;



portd.f0=0;

TRISC.f1=1;


Tmr0=0x0c;
Tmr1l=0x00;
Tmr1h=0x00;
T1CON=0b00000011;



intcon=0b10100000;
option_reg=0b00010111;
}

void Change_Display()
{
#line 378 "C:/My Data/College Courses/5_Fifth HEM term Fall 2022/Embeded Systems/Final Project/Integration V2/Mikro C/IntegrationV2.c"
 if (buttonCounter==0)
 {
 lCD_Home();
 delay_ms(10);
 LCD_send_string(temperature_String);
 LCD_second_row();
 LCD_send_string(heartbeat_String);
 }
 else if(buttonCounter==1)
 {

 lCD_Home();
 delay_ms(10);
 LCD_send_string(temperature_String);
 }
 else if(buttonCounter==2)
 {
 lCD_Home();
 delay_ms(10);
 LCD_send_string(heartbeat_String);

 }
}

void interrupt(){

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

 if(intcon.f2=1)
 {
 intcon.f2=0;
 }
interruptCounter++;
UartCounter++;
 if(interruptCounter==241)
 {
 beatpermin=(TMR1H<<8)|(TMR1L)*4;
 TMR1H=0;
 TMR1L=0;
 interruptCounter=0;
 }
 if(UartCounter==160)
 {uartflag=1;
 UartCounter=0;}
tmr0=0x0c;
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
