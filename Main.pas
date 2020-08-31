unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JPEG, PNGImage, System.Generics.Collections;

type
  TGameItem = class
    Image:TPNGImage;
    name:String;
    coords:TPoint;
    RoomN:Shortint; //0 - inventory -1 - some strange place
    constructor Create(const n:String;const RN:ShortInt; const coord:TPoint);
  end;
  TRoom = class
    Image:TJPEGImage;
    class var fRoomN:Byte;
    class procedure setRoomN(const D:Byte);static;
    class property RoomN:Byte read fRoomN write setRoomN;
    constructor Create(const N:Byte);
  end;
  TForm1 = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    Wid20,
    Hei20:Word;
    basementLight:Boolean;
    BackBuffer:TBitmap;
    Room:TList<TRoom>;
    Items:TList<TGameItem>;
    FlashLight:TPNGImage;
    FlashCoord:TPoint;
    procedure CreateItems;
    procedure reDraw;
    procedure Clicked(I:TGameItem);
    function ItemClicked(const X,Y:Word):Boolean;
    function FindItem(const n:String):TGameItem;
  public
    LiftAt:Byte;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

constructor TRoom.Create(const N:Byte);
begin
  Image:=TJPEGImage.Create;
  Image.LoadFromFile('RES\Rooms\r'+IntToStr(N)+'.jpg');
end;

constructor TGameItem.Create(const n:String;const RN:ShortInt; const coord:TPoint);
begin
  Image:=TPNGImage.Create;
  Image.LoadFromFile('RES\Objects\'+n+'.png');
  RoomN:=RN;
  name:=n;
  Coords:=Coord;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
 var z:TRoom;x:TGameItem;
begin
 for z in Room do
     z.Destroy;
 Room.Destroy;
 for x in Items do
     x.Destroy;
 Items.Destroy;
end;

function TForm1.ItemClicked(const X,Y:Word):Boolean;
 var I:TGameItem;
Begin
  Result:=false;
  for I in Items do
    if I.RoomN=TRoom.RoomN then
       if (X>I.coords.X)and(X<I.coords.X+I.Image.Width)and(Y>I.coords.Y)and(Y<I.coords.Y+I.Image.Height) then
         Begin
          Clicked(I);
          Result:=true;
          Exit;
         End;
End;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not ItemClicked(X,Y) then
    Begin
      if (x>ClientWidth-Wid20)and(ABS(y-(clientHeight div 2))<ClientHeight*0.1) then TRoom.RoomN:=4 else
      if (x<Wid20)and(ABS(y-(clientHeight div 2))<ClientHeight*0.1) then TRoom.RoomN:=3 else
      if (y>ClientHeight-Hei20)and(ABS(x-(clientWidth div 2))<ClientWidth*0.1) then TRoom.RoomN:=2 else
      if (y<Hei20)and(ABS(x-(clientWidth div 2))<ClientWidth*0.1) then TRoom.RoomN:=1;
    End;
  Form1.Repaint;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  reDraw;
  if (TRoom.RoomN in [69..85])and((FindItem('flashlight')<>nil)and(FindItem('flashlight').RoomN=0)) then
    Begin
      FlashCoord.x:=x;
      FlashCoord.y:=y;
    End

end;

procedure TForm1.reDraw;
 var I:TGameItem;
begin
   if not(TRoom.RoomN in [69..85])or(BasementLight)or((FindItem('flashlight')<>nil)and(FindItem('flashlight').RoomN=0)) then
     Begin
       Backbuffer.Canvas.Draw(0,0,Room[TRoom.RoomN].Image);
       for I in Items do
        if I.RoomN=TRoom.RoomN then
           Backbuffer.Canvas.Draw(I.coords.X,I.coords.Y,I.Image);
       if (TRoom.RoomN in [69..85])and((FindItem('flashlight')<>nil)and(FindItem('flashlight').RoomN=0)) then
           Backbuffer.Canvas.Draw(Flashcoord.x-480,Flashcoord.3y-240,FlashLight);
     End
       else
      BackBuffer.Canvas.Draw(0,0,Room[0].Image);
   canvas.Draw(0,0,BackBuffer);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
 reDraw;
end;

procedure TForm1.CreateItems;
begin
  FlashLight:=TPNGImage.Create;
  FlashLight.LoadFromFile('RES\Objects\light.png');
  Items:=TList<TGameItem>.create;
  Items.Add(TGameItem.Create('elb',15,TPoint.Create(163,67)));
  Items.Add(TGameItem.Create('elb',18,TPoint.Create(145,67)));
  Items.Add(TGameItem.Create('elb',44,TPoint.Create(163,67)));
  Items.Add(TGameItem.Create('elb',69,TPoint.Create(121,67)));
  Items.Add(TGameItem.Create('elb',46,TPoint.Create(115,67)));
  Items.Add(TGameItem.Create('elbup',17,TPoint.Create(7,43)));
  Items.Add(TGameItem.Create('elbdn',17,TPoint.Create(7,80)));
  Items.Add(TGameItem.Create('utkey',29,TPoint.Create(292,171)));
  Items.Add(TGameItem.Create('corlockrclsd',12,TPoint.Create(49,94)));
  Items.Add(TGameItem.Create('corlockropn',-1,TPoint.Create(49,94)));
  Items.Add(TGameItem.Create('druglckrcls',14,TPoint.Create(247,65)));
  Items.Add(TGameItem.Create('druglckropn',-1,TPoint.Create(247,65)));
  Items.Add(TGameItem.Create('ffoodwindclsd',19,TPoint.Create(52,51)));
  Items.Add(TGameItem.Create('ffoodwindopen',-1,TPoint.Create(52,48)));
  Items.Add(TGameItem.Create('hardwarewindclsd',21,TPoint.Create(385,52)));
  Items.Add(TGameItem.Create('hardwarewindopen',-1,TPoint.Create(385,52)));
  Items.Add(TGameItem.Create('hardwarelckrclsd',21,TPoint.Create(436,148)));
  Items.Add(TGameItem.Create('hardwarelckropen',-1,TPoint.Create(436,148)));
  Items.Add(TGameItem.Create('fuseboxclsd',85,TPoint.Create(341,49)));
  Items.Add(TGameItem.Create('fuseboxopen',-1,TPoint.Create(341,49)));
  Items.Add(TGameItem.Create('helidrclsd',1,TPoint.Create(150,112)));
  Items.Add(TGameItem.Create('helidropen',-1,TPoint.Create(150,112)));
  Items.Add(TGameItem.Create('helifuelclsd',1,TPoint.Create(96,120)));
  Items.Add(TGameItem.Create('helifuelopen',-1,TPoint.Create(96,120)));
end;

procedure TForm1.FormShow(Sender: TObject);
 var z:Byte;
begin
 BackBuffer:=TBitmap.Create;
 BackBuffer.Width:=480;
 BackBuffer.Height:=239;
 Room:=TList<TRoom>.create;
 Wid20:=Round(ClientWidth*0.1);
 Hei20:=Round(ClientHeight*0.1);
 for z := 0 to 89 do
     Room.Add(TRoom.Create(z));
 TRoom.fRoomN:=21;
 CreateItems;
 LiftAt:=2;
 BasementLight:=false;
end;

procedure TForm1.Clicked(I: TGameItem);
begin
  if I.name='elb' then
    Begin
      case TRoom.RoomN of
         46:LiftAt:=4;
         15:LiftAt:=3;
         18:LiftAt:=2;
         44:LiftAt:=1;
         69:LiftAt:=0;
      end;
    End else
  if I.name='elbup' then
    Begin
      if LiftAt<4 then LiftAt:=LiftAt+1
    End else
  if I.name='elbdn' then
    Begin
      if LiftAt>0 then LiftAt:=LiftAt-1
    End;
  if I.name='utkey' then
    Begin
      if I.RoomN<>0 then I.RoomN:=0
    End else
  if I.name='corlockrclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('corlockropn').RoomN:=12;
      if FindItem('glove')=nil then
        Begin
          Items.Add(TGameItem.create('glove',12,TPoint.Create(50,200)));
          Items.Add(TGameItem.create('can',12,TPoint.Create(100,190)));
        End;
    End else
  if I.name='corlockropn' then
    Begin
      I.RoomN:=-1;
      FindItem('corlockrclsd').RoomN:=12;
    End else
    if I.name='druglckrcls' then
    Begin
      I.RoomN:=-1;
      FindItem('druglckropn').RoomN:=14;
      if FindItem('medkit')=nil then
        Begin
          Items.Add(TGameItem.create('medkit',14,TPoint.Create(247,170)));
        End;
    End else
  if I.name='druglckropn' then
    Begin
      I.RoomN:=-1;
      FindItem('druglckrcls').RoomN:=14;
    End else
  if I.name='ffoodwindclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('ffoodwindopen').RoomN:=19;
    End else
  if I.name='ffoodwindopen' then
    Begin
      I.RoomN:=-1;
      FindItem('ffoodwindclsd').RoomN:=19;
    End else
  if I.name='hardwarewindclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('hardwarewindopen').RoomN:=21;
    End else
  if I.name='hardwarewindopen' then
    Begin
      I.RoomN:=-1;
      FindItem('hardwarewindclsd').RoomN:=21;
    End else
  if I.name='hardwarelckrclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('hardwarelckropen').RoomN:=21;
      if FindItem('flashlight')=nil then
        Begin
          Items.Add(TGameItem.create('flashlight',21,TPoint.Create(380,210)));
        End;
    End else
  if I.name='hardwarelckropen' then
    Begin
      I.RoomN:=-1;
      FindItem('hardwarelckrclsd').RoomN:=21;
    End else
  if I.name='fuseboxclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('fuseboxopen').RoomN:=85;
    End else
  if I.name='fuseboxopen' then
    Begin
      I.RoomN:=-1;
      FindItem('fuseboxclsd').RoomN:=85;
    End else
  if I.name='helidrclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('helidropen').RoomN:=1;
    End else
  if I.name='helidropen' then
    Begin
      I.RoomN:=-1;
      FindItem('helidrclsd').RoomN:=1;
    End else
  if I.name='helifuelclsd' then
    Begin
      I.RoomN:=-1;
      FindItem('helifuelopen').RoomN:=1;
    End else
  if I.name='helifuelopen' then
    Begin
      I.RoomN:=-1;
      FindItem('helifuelclsd').RoomN:=1;
    End else
  if I.name='flashlight' then
    Begin
      I.RoomN:=0;
    End;

end;

function TForm1.FindItem(const n: string):TGameItem;
 var I:TGameItem;
begin
 result:=nil;
 for I in Items do
  if I.name=n then
    Begin
      Result:=I;
      exit;
    End;
end;

class procedure TRoom.setRoomN(const D: Byte);
begin
  case RoomN of
    1:Case D of
       1:Begin
          if Form1.FindItem('helidropen').RoomN=1 then
             fRoomN:=89
         End;
       4:fRoomN:=2
      End;
    2:Case D of
       2:fRoomN:=3;
       3:fRoomN:=1
      End;
    3:Case D of
       1:fRoomN:=2;
       2:fRoomN:=4
      End;
    4:Case D of
       1:fRoomN:=3;
       2:fRoomN:=5;
       3:fRoomN:=7;
      End;
    5:Case D of
       1:fRoomN:=4;
       2:fRoomN:=6;
       3:fRoomN:=28;
      End;
    6:Case D of
       1:fRoomN:=5;
       3:fRoomN:=30;
      End;
    7:Case D of
       3:fRoomN:=8;
       4:fRoomN:=4;
      End;
    8:Case D of
       2:fRoomN:=9;
       3:fRoomN:=10;
       4:fRoomN:=7;
      End;
    9:Case D of
       1:fRoomN:=8;
      End;
    10:Case D of
       1:fRoomN:=12;
       3:fRoomN:=11;
       4:fRoomN:=8;
      End;
    11:Case D of
       4:fRoomN:=10;
      End;
    12:Case D of
       1:fRoomN:=13;
       2:fRoomN:=10;
      End;
    13:Case D of
       1:fRoomN:=15;
       4:fRoomN:=14;
       2:fRoomN:=12;
      End;
    14:Case D of
       3:fRoomN:=13;
      End;
    15:Case D of
       3:fRoomN:=16;
       2:fRoomN:=13;
       1:if Form1.LiftAt=3 then fRoomN:=17;
      End;
    16:Case D of
       4:fRoomN:=15;
      End;
    //elevator
    17:Case D of
       2:Case Form1.LiftAt of
          0:fRoomN:=69;
          1:fRoomN:=44;
          2:fRoomN:=18;
          3:fRoomN:=15;
          //check key
          4:Begin
             if Form1.FindItem('utkey').RoomN=0 then
                fRoomN:=46;
            End;
         End;
      End;
    18:Case D of
       1:if Form1.LiftAt=2 then fRoomN:=17;
       2:fRoomN:=20;
       3:fRoomN:=19;
      End;
    19:Case D of
       4:fRoomN:=18;
      End;
    20:Case D of
       1:fRoomN:=18;
       2:fRoomN:=22;
       4:fRoomN:=21;
      End;
    21:Case D of
       3:fRoomN:=20;
      End;
    22:Case D of
       1:fRoomN:=20;
       2:fRoomN:=25;
       3:fRoomN:=23;
       4:fRoomN:=24;
      End;
    23:Case D of
       4:fRoomN:=22;
      End;
    24:Case D of
       3:fRoomN:=22;
      End;
    25:Case D of
       1:fRoomN:=22;
       2:fRoomN:=26;
       4:fRoomN:=27;
      End;
    26:Case D of
       1:fRoomN:=25;
      End;
    27:Case D of
       3:fRoomN:=25;
       4:fRoomN:=28;
      End;
    28:Case D of
       2:fRoomN:=29;
       3:fRoomN:=27;
       4:fRoomN:=5;
      End;
    29:Case D of
       1:fRoomN:=28;
      End;
    30:Case D of
       3:fRoomN:=31;
       4:fRoomN:=6;
      End;
    31:Case D of
       2:fRoomN:=32;
       3:fRoomN:=33;
       4:fRoomN:=30;
      End;
    32:Case D of
       1:fRoomN:=31;
      End;
    33:Case D of
       1:fRoomN:=38;
       2:fRoomN:=34;
       3:fRoomN:=37;
       4:fRoomN:=31;
      End;
    34:Case D of
       1:fRoomN:=33;
       2:fRoomN:=36;
       3:fRoomN:=35;
      End;
    35:Case D of
       2:fRoomN:=83;
       4:fRoomN:=34;
      End;
    //outside down
    36:Case D of
       1:fRoomN:=34;
       2:fRoomN:=68;
       3:fRoomN:=88;
       4:fRoomN:=51;
      End;
    37:Case D of
       4:fRoomN:=33;
      End;
    38:Case D of
       1:fRoomN:=40;
       2:fRoomN:=33;
       3:fRoomN:=39;
      End;
    39:Case D of
       4:fRoomN:=38;
      End;
    40:Case D of
       1:fRoomN:=44;
       2:fRoomN:=38;
       3:fRoomN:=41;
       4:fRoomN:=42;
      End;
    41:Case D of
       4:fRoomN:=40;
      End;
    42:Case D of
       2:fRoomN:=43;
       3:fRoomN:=40;
       4:fRoomN:=60;
      End;
    43:Case D of
       1:fRoomN:=42;
      End;
    44:Case D of
       1:if Form1.LiftAt=1 then fRoomN:=17;
       2:fRoomN:=40;
       3:fRoomN:=47;
       4:fRoomN:=45;
      End;
    45:Case D of
       3:fRoomN:=44;
      End;
    46:Case D of
       1:if Form1.LiftAt=4 then fRoomN:=17;
      End;
    47:Case D of
       3:fRoomN:=48;
       4:fRoomN:=44;
      End;
    //outside left
    48:Case D of
       1:fRoomN:=49;
       2:fRoomN:=66;
       3:fRoomN:=68;//death
       4:fRoomN:=47;
      End;
    49:Case D of
       1:fRoomN:=68;
       2:fRoomN:=48;
       3:fRoomN:=68;//death
      End;
    51:Case D of
       2:fRoomN:=68;//death
       3:fRoomN:=36;
       4:fRoomN:=52;
      End;
    52:Case D of
       2:fRoomN:=68;//death
       3:fRoomN:=51;
       4:fRoomN:=86;
      End;
    54:Case D of
       1:fRoomN:=55;
       2:fRoomN:=68;//death
       3:fRoomN:=87;
       4:fRoomN:=68;
      End;
    55:Case D of
       1:fRoomN:=56;
       2:fRoomN:=54;
       4:fRoomN:=68;//death
      End;
    56:Case D of
       1:fRoomN:=57;
       2:fRoomN:=55;
       4:fRoomN:=68;//death
      End;
    57:Case D of
       1:fRoomN:=58;
       2:fRoomN:=56;
       4:fRoomN:=68;//death
      End;
    58:Case D of
       1:fRoomN:=68;
       2:fRoomN:=57;
       3:fRoomN:=59;
       4:fRoomN:=68;//death
      End;
    59:Case D of
       1:fRoomN:=68;//death
       3:fRoomN:=61;
       4:fRoomN:=58;
      End;
    60:Case D of
       1:fRoomN:=68;//death
       3:fRoomN:=42;
       4:fRoomN:=61;
      End;
    61:Case D of
       1:fRoomN:=68;//death
       3:fRoomN:=60;
       4:fRoomN:=59;
      End;
    62:Case D of
       1:fRoomN:=63;
       2:fRoomN:=68;//death
       3:fRoomN:=68;
       4:fRoomN:=88;
      End;
    63:Case D of
       1:fRoomN:=64;
       2:fRoomN:=62;
       3:fRoomN:=68;//death
      End;
    64:Case D of
       1:fRoomN:=65;
       2:fRoomN:=63;
       3:fRoomN:=68;//death
      End;
    65:Case D of
       1:fRoomN:=66;
       2:fRoomN:=64;
       3:fRoomN:=68;//death
      End;
    66:Case D of
       1:fRoomN:=48;
       2:fRoomN:=65;
       3:fRoomN:=68;//death
      End;
    //basement
    69:Case D of
       1:if Form1.LiftAt=0 then fRoomN:=17;
       3:fRoomN:=77;
       4:fRoomN:=70;
      End;
    70:Case D of
       3:fRoomN:=69;
       4:fRoomN:=71;
      End;
    71:Case D of
       2:fRoomN:=72;
       3:fRoomN:=70;
       4:fRoomN:=74;
      End;
    72:Case D of
       1:fRoomN:=71;
       2:fRoomN:=73;
      End;
    73:Case D of
       1:fRoomN:=72;
       2:fRoomN:=75;
      End;
    74:Case D of
       3:fRoomN:=71;
      End;
    75:Case D of
       1:fRoomN:=73;
       3:fRoomN:=76;
      End;
    76:Case D of
       4:fRoomN:=75;
      End;
    77:Case D of
       3:fRoomN:=78;
       4:fRoomN:=69;
      End;
    78:Case D of
       2:fRoomN:=79;
       4:fRoomN:=77;
      End;
    79:Case D of
       1:fRoomN:=78;
       2:fRoomN:=80;
      End;
    80:Case D of
       1:fRoomN:=79;
       2:fRoomN:=81;
       4:fRoomN:=84;
      End;
    81:Case D of
       1:fRoomN:=80;
       2:fRoomN:=82;
      End;
    82:Case D of
       1:fRoomN:=81;
       4:fRoomN:=83;
      End;
    83:Case D of
       1:fRoomN:=35;
       3:fRoomN:=82;
      End;
    84:Case D of
       3:fRoomN:=80;
       4:fRoomN:=85;
      End;
    85:Case D of
       3:fRoomN:=84;
      End;
    86:Case D of
       2:fRoomN:=68;//death
       3:fRoomN:=52;
       4:fRoomN:=87;
      End;
    87:Case D of
       2:fRoomN:=68;
       3:fRoomN:=86;
       4:fRoomN:=54;
      End;
    88:Case D of
       2:fRoomN:=68;
       3:fRoomN:=62;
       4:fRoomN:=36;
      End;
    89:Case D of
       4:fRoomN:=1;
      End;
  end;
  Form1.Caption:=IntToStr(fRoomN)
end;

end.
