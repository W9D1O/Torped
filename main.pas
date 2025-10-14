program editor;
uses
  raylib;
const
  alto = 600;
  ancho = 800;
  ltrx = 14;
  ltry = 28;
type
  LC = ^LPchar;
  LPchar = record
    l:integer;
    posi:TVector2;
    b:boolean;
    ubi:integer;
    sig:LC;
  end;
  TCursor = record
    carac:integer;
    posi: TVector2;
    velo:real;
    colo:TColorB;
  end;

//##################################//
//                                      //
var // No se usan variables globales(?)
  blinking:integer= 0;
  press:boolean=false;
  arch:string = 'mi_archivo.txt';
//                                    //
//##################################//


procedure atras2(var c:LC;av:longint;var paux:LC;posi:TVector2;var ubi:integer;e_ant,e_ult:LC;var agr:boolean);
var
  aux ,a_ant,a_ult:lc;
  vf:boolean = false;
begin
  new(aux);
  aux^.l:=av;
  aux^.posi.y:= posi.y;
  aux^.posi.x:= posi.x; 
  aux^.b:= false;
  aux^.ubi:= ubi;
  aux^.sig:= nil;
  ubi:= ubi + 1;
  if(e_ult <> nil)then begin
    if e_ant = nil then begin
      a_ant:= e_ult;
      a_ult:=e_ult^.sig;
    end
    else
      begin
        a_ant:=e_ant^.sig;
        a_ult:=e_ult^.sig;
      end;
  end;
  if (c = nil)   then begin
    c:= aux;
    vf:= true;
    end
  else begin
    if (aux^.posi.x <= posi.x) or (aux^.posi.y <> paux^.posi.y) then begin
      if(aux^.posi.x = c^.posi.x) and (aux^.posi.y = c^.posi.y)then begin
        aux^.sig:= c;
        c:= aux;
        agr:= true;
        ubi:= 0;
      end
      else
        if(e_ult <> nil) and (aux^.posi.x <= paux^.posi.x) and (aux^.posi.y <= paux^.posi.y)then begin
          if (a_ult = nil) or (a_ult^.posi.x > posi.x)then begin
            a_ant:= e_ant;
            a_ult:= e_ult;
          end;
          a_ant^.sig:= aux;
          aux^.sig:= a_ult;
          agr:= true;
          ubi:= 0;
      end
      else begin
    paux^.sig:= aux;
    vf:= true;
  end;
  end;
end;
if vf then
  paux:= aux;
{if (agr) and (aux^.posi.y = paux^.posi.y) then
  paux^.posi.x:= paux^.posi.x + ltrX;}
end;

procedure apreto(var c:LC;var ult:LC;var posi:TVector2;var cont:integer;
                 var lf:TVector2;var cpaux:real;var ubi:integer;e_ant,e_ult:LC;var agr:boolean);
var
  av:integer;
begin
  agr:= false;
  av:=GetCharPressed();
  if av <> 0 then begin
    cont:= cont + 1;
    atras2(c,av,ult,posi,ubi,e_ant,e_ult,agr);
    posi.x:= posi.x + ltrX;
    cpaux:= posi.y;
    //writeln(cont); //Cursor ((char(219)))
  end;
end;

procedure desplazamiento(var cpos,lf:TVector2;c,ult:LC;var p:TVector2;cw,ch:integer;
  cpaux:real;var pcont,cont,act:integer;bs,agr:boolean;ubi_act:integer;var ent:boolean);
var
  aux:LC;
begin

  if cpos.y = c^.posi.y then
  pcont:= pcont + 1;
if (bs) or (agr)then begin
  if ((pcont <> cont) and (cpos.y = c^.posi.y)) then begin
    c^.posi.x := act;
    act:= act + ltrX;
  end;
end;
if(cpaux <> cpos.y) and (cpos.y <> c^.posi.y) then begin //vos me das problemas cuando cambio de linea, volves la linea anterior a 0 y no quiero que hagas eso
  if c^.posi.y <> p.y then begin
      p.y:= c^.posi.y;
      p.x:= 0;
    end;
    if p.x >= 0 then
      p.x:= c^.posi.x;
    if(c^.posi.y = p.y) and (p.x < 0) then begin
      c^.posi.x := c^.posi.x - p.x;
      
    end;

  end;

  if(cpos.y + ltrY >  ch)then begin
    lf.y:= lf.y - ltrY;
    cpos.y:= cpos.y -ltrY;
  end;
  {if(cpos.x > cw) and (c^.posi.x = cpos.x)then begin
    lf.x:= lf.x - ltrX;
    c^.posi.x:= c^.posi.x - ltrX;
    cpos.x:= cw - ltrX; 
  end;}
  writeln(lf.x:2:2,' ',act);
  if(cpos.x < 0) and (c^.ubi > 0) and (c^.posi.x = cpos.x) and (c^.posi.y = cpos.y)then begin
    lf.x:= lf.x + ltrX;
    cpos.x:= 0;
  end;
  if lf.x > 0 then
    c^.posi.x:= c^.posi.x + ltrX;

  if(cpos.x + ltrX > cw)then begin
    lf.x:= lf.x -ltrX;
    cpos.x:= cpos.x - ltrX;
  end;
  if lf.x < 0 then begin
    c^.posi.x:=c^.posi.x + lf.x;
  end;
  if lf.y < 0 then 
  c^.posi.y:= c^.posi.y + lf.y;
  aux:= c^.sig;
  if c^.sig <> nil then
    if c^.posi.x = aux^.posi.x then
      aux^.posi.x:= aux^.posi.x + ltrX;
end;
function corre(valo:real):boolean;
var
  vf:boolean;
  dir:integer;
  begin
    if (IsKeyDown(KEY_RIGHT)) or (IsKeyDown(KEY_LEFT))then
      dir:= 6
    else
      dir:= 9;
    vf:= false;
    if valo = dir then
      vf:= true;
    corre:= vf;
  end;

procedure mov_c(var posi:TVector2;ch,cw:integer;ult:LC;cont:integer;var velo:real;var c:LC;ubi:integer);
var
  max_m:integer;
begin
  max_m:= ltrX * cont;
  if IsKeyDown(KEY_RIGHT)then begin
    velo:= velo + 1;
    if corre(velo) then
      posi.x:= posi.x + ltrX;
    if posi.x > cw  then begin
      posi.x:=  posi.x - ltrX;
    end;
  end;
    if IsKeyDown(KEY_LEFT) then begin
      velo:= velo + 1;
      if corre(velo)then begin
      posi.x:= posi.x - ltrX;
      {if posi.x < 0 then
        posi.x:= 0;}
    end;
  end;
  if(posi.y >= 0) {and (posi.y < ch)}then begin
  if IsKeyDown(KEY_UP) then begin
    velo:= velo + 1;
    if corre(velo)then
    if posi.y > 0 then 
      posi.y:= posi.y - ltrY;
    end;
    if IsKeyDown(KEY_DOWN) then begin
      if(ult <> nil) and (posi.y < ult^.posi.y)  then
        velo:= velo + 1;
        if corre(velo)then
        posi.y:= posi.y + ltrY
    end;
  end;
  if corre(velo)then
    velo:= 0;
end;

procedure cur_blink(var colo:TColorB);
var
  av:integer;
begin
  av:= GetCharPressed();
  if(IsKeyDown(KEY_UP)) or (IsKeyDown(KEY_LEFT)) or (IsKeyDown(KEY_DOWN)) or (IsKeyDown(KEY_RIGHT)) or (IsKeyDown(KEY_BACKSPACE)) or (av <> 0)then
    blinking:= 0;
  blinking:= blinking + 1;
  colo:= GetColor($E4E4EFFF);
  if Blinking = 60 then begin
    blinking:= -45;
    colo := GetColor($181818FF)
  end
  else
    if blinking < 0 then
      colo := GetColor($181818FF);
end;

procedure enter(var cpos,posi:TVector2;var ent:boolean);
begin
  if (IsKeyPressed(KEY_ENTER)) and (not IsKeyDown(KEY_LEFT_ALT))then begin
    ent:= true;
    cpos.y:= cpos.y + ltrY;
    cpos.x:= 0;
    posi.x:= 0;
    posi.y:= 0;
  end;
end;

procedure pos_car(cpos:TVector2;c:LC;var e_ult,e_ant:LC);
begin
  if(cpos.y = 0) and (cpos.x = 0)then begin
    e_ult:= nil;
    e_ant:= nil;
  end;
  if(e_ant <> nil) and (e_ult^.ubi = 0) and ((e_ult = e_ant) {or (e_ant^.ubi > e_ult^.ubi)} )then
    e_ant:= nil;
  if (e_ant <> nil) and (e_ant^.ubi > e_ult^.ubi) and (e_ult^.ubi = 0)then
    e_ant:= nil;
  if(e_ant <> nil) and (e_ult^.ubi <> 0) and (e_ant^.ubi > e_ult^.ubi) then
    if c^.ubi - 1 = e_ult^.ubi then
      e_ant:= c;
  if (c^.posi.x + ltrX = cpos.x) and (c^.posi.y = cpos.y) then
    e_ult:=c;
  if(e_ult <> nil) and (e_ult^.ubi >= 1) and (c^.ubi + 1 = e_ult^.ubi) then
   e_ant:= c; 
  if(cpos.y > 0) and (cpos.x = 0) then begin
    if (c^.posi.y = cpos.y) and (c^.posi.x = cpos.x)then
      e_ult:= c;
    if (e_ult <> nil) and (e_ult^.ubi - 1 = c^.ubi) then
      e_ant:= c;
  end;

end;

procedure eliminar_c(var e_ant,e_ult,ult,c:LC;var posi:TVector2;var bs:boolean;var ubi:integer;var velo:real);
begin
  if IsKeyDown(KEY_BACKSPACE)then
    velo:= velo + 1;
  if corre(velo) and (c <> nil) and (e_ult <> nil) then begin
    velo:= 0;
  if e_ult = c then begin
    bs:= true;
    posi.x := e_ult^.posi.x;    
    posi.y := e_ult^.posi.y;    
    c:= c^.sig;
    dispose(e_ult);
    ubi:= 0;
  end
  else
    begin
            bs:= true;
            e_ant^.sig:= e_ult^.sig;
            if e_ult = ult then
                ult:= e_ant;
            posi.x := e_ult^.posi.x;    
            posi.y := e_ult^.posi.y;    
            dispose(e_ult);
            e_ult:= e_ant;
            ubi:= 0;
end;
end;

end;

procedure retro_bsc(ult:LC;var posi:TVector2); // vuelta de linea cuando se apreta la tecla backspace y no hay nada que borrar
begin
  if IsKeyPressed(KEY_BACKSPACE) then begin
    if ult <> nil then
    if posi.y <> ult^.posi. y then begin
      if posi.y - ltrY = ult^.posi.y then begin
        posi.x:= ult^.posi.x + ltrX;
      end;
      posi.y := posi.y - ltrY;
    end;
    if(ult = nil) and (posi.y > 0) THEN
    posi.y:=posi.y - ltrY;
  end;
end;

procedure render(var c:lc;f:tfont;var lf:tvector2;var mpa:text;
                var cont:integer;var cur:TCursor;posi:TVector2;
                cw,ch:integer;cpaux:real;var e_ant,e_ult,ult:LC;
                var ubi:integer;agr:boolean);
var
    aux:LC;
    pcont,act,ubi_a,ubi_act:integer;
    bs,ent:boolean;
begin
  bs:= false;
  ent:= false;
  pcont:= 0;
  if c <> nil then
   act:= round(c^.posi.x)
  else
  act:= 0; 
ubi_act:= 0;
  //writeln(act);
  cur_blink(cur.colo);
  enter(cur.posi,posi,ent);
  DrawTextCodepoint(f,cur.carac, cur.posi, ltrY,cur.colo );
  if cur.posi.x <> 0 then
    eliminar_c(e_ant,e_ult,ult,c,cur.posi,bs,ubi,cur.velo);
  //retro_bsc(ult,cur.posi);
  aux:= c;
  ubi_a:= ubi;
  while (aux <> nil) do begin
    if (cur.posi.x = 0.0) and (cur.posi.x = aux^.posi.x) and (cur.posi.y = aux^.posi.y) then
      ubi_act:= aux^.ubi;
    desplazamiento(cur.posi,lf,aux,ult,posi,cw,ch,cpaux,pcont,cont,act,bs,agr,ubi_act,ent);
    pos_car(cur.posi,aux,e_ult,e_ant);
    if ubi_a = 0 then begin
      aux^.ubi:= ubi;
      ubi:= ubi + 1;
    end;
    DrawTextCodepoint(f,aux^.l, aux^.posi, ltrY, GetColor($E4E4EFFF));
    aux:=aux^.sig;
    if aux = nil then begin
      lf.x:= 0;
      lf.y:= 0;
    end;
  end;
  cont:= pcont;
  mov_c(cur.posi,ch,cw,ult,cont,cur.velo,c,ubi_act);
  //writeln(cur.posi.x:2:2)
  
end;

procedure lectura(var mpa:text;var posi:TVector2;var paux:LC;var c:LC;var ubi:integer;e_ant,e_ult:LC;var agr:boolean);
var
  cara:char;
begin
  assign(mpa,arch);

  reset(mpa);
  while not eof(mpa) do begin
    if eoln(mpa) then begin
      readln(mpa,cara);
      cara:= #27;
      posi.y := posi.y + ltry;
      posi.x:= 0;
    end
    else
      begin
      read(mpa,cara);
      atras2(c,ord(cara),paux,posi,ubi,e_ant,e_ult,agr);
      //atras(c,ord(cara),paux,posi,ubi);
      posi.x:= posi.x + ltrx;
  end;
  end;
  Close(mpa);
  posi.x:= 0;
  posi.y:= 0;
end;
procedure escritura(c:LC;var mpa:text);
var
  y:real;
begin
  y:= 0;
  assign(mpa,arch);
  rewrite(mpa);
  while c <> nil do begin
    if c^.posi.y < 0 then
      y:= c^.posi.y;
    while y <> c^.posi.y do begin
      writeln(mpa);
      y:= y + ltrY;
    end;
    if y <> c^.posi.y then begin
      write(mpa);
      writeln(mpa);
      y:= y + ltrY; 
    end
    else
    if c^.b then begin
      write(mpa,char(c^.l));
      writeln(mpa);
      y:= y + ltrY;
  end
  else
    begin
    write(mpa,char(c^.l));
  end;
    c:= c^.sig;
end;
Close(mpa);
end;
procedure conf_win(var cw,ch:integer);
begin
  cw:= GetScreenWidth();
  ch:= GetScreenHeight();
  if (IsKeyDown(KEY_LEFT_ALT)) and (IsKeyDown(KEY_ENTER)) then
    ToggleBorderlessWindowed();
end;
var
  cur:TCursor;
  c,ult,e_ult,e_ant:lc;
  f:TFont;
  icono:TImage;
  posi,lf:TVector2;
  cont,ch,cw,ubi_c:integer;
  mpa:text;
  cpaux:real;
  agr:boolean;
  begin
  SETTRACELOGLEVEL(LOG_ERROR);
  c:= nil;
  e_ult:= nil;
  e_ant:= nil;
  ubi_c:= 0;
  cont:= 0;
  lf.x:= 0;
  lf.y:= 0;
  posi.x:= 0;
  cpaux:= 0;
  ch:= alto;
  cw:= ancho;
  icono:= LoadImage('pity9.png');
  posi.y:= 0;
  cur.posi.x:= 0;
  cur.posi.y:= 0;
  cur.velo:= 0;
  cur.carac:= 9601; //95
  SetTargetFPS(60);
  InitWindow(ancho,alto,'Editor de Texto con Raylib');
  SetWindowIcon(icono);
  SetWindowState(FLAG_WINDOW_RESIZABLE);
  //SetWindowOpacity(0.9);
  f:= LoadFontEx('Font/HackNerdFont-Regular.ttf', 16,nil, 9700);
  if FileExists('mi_archivo.txt') then
    lectura(mpa,cur.posi,ult,c,ubi_c,e_ant,e_ult,agr);
  while not WindowShouldClose() do Begin
  conf_win(cw,ch);
  BeginDrawing();
  ClearBackground(GetColor($181818FF));
  apreto(c,ult,cur.posi,cont,lf,cpaux,ubi_c,e_ant,e_ult,agr);
  render(c,f,lf,mpa,cont,cur,posi,cw,ch,cpaux,e_ant,e_ult,ult,ubi_c,agr);
  EndDrawing();
  End;
  UnLoadFont(f);
  UnloadImage(icono);
  CloseWindow();
  escritura(c,mpa);
  end.
