program torped;

uses
  raylib;

const
  ancho = 800;
  alto = 600;
  buffer = 1024;
  FontSizeY = ancho/25;
  FontSizeX = FontSizeY/2;
type
  Tchar = record
    posicion:TVector2;
    unicode:integer;
  end;
   
  VTchar = record
    cantC:integer;
    color:TColor; //Puede que el color este meio al pedo.
    caracteres:array of Tchar;
  end;

  TCursor = record
    indexMaxPos	      : integer;
    maxPos            : TVector2;
    posicion	      : TVector2;
    caracter	      : integer;
    color	      : TColor;
    end;	      

//devuelve la diferencia entre en ancho de la pantalla y la posicion del cursor
function calcularOffset(posi:TVector2):TVector2;
var
  resul:TVector2;
begin
  resul.x:= 0;
  resul.y:= 0;
  posi.x:= posi.x + FontSizeX;
  posi.y:= posi.y + FontSizeY;
  if(posi.x >= ancho)then
    resul.x:= ancho - posi.x;
  if(posi.y > alto)then
    resul.y:= alto - posi.y;
  calcularOffset:= resul;
end;


//Parece que datos funciona como si fuera un puntero, por el momento usar variables auxiliares
procedure rederizarCaracteres(f:TFont; datos:VTchar; cursor:Tcursor);
var 
i:integer;
offset:TVector2;
posiAux:TVector2;
begin
  offset.x:= 0;
  offset.y:= 0;
  if(datos.cantC > 0)then begin
    offset:= calcularOffset(cursor.posicion);
  for i:= 1 to datos.cantC do begin
      posiAux.x:= datos.caracteres[i].posicion.x + offset.x;
      posiAux.y:= datos.caracteres[i].posicion.y + offset.y;
      DrawTextCodepoint(f,datos.caracteres[i].unicode,posiAux,FontSizeY,datos.color);
    end;
  end;
  //Hasta que no se haga un salto de linea el cursor siempre va a a estar una posicion
  //adelante del ultimo caracter, con esa condicion solo se acomoda de manera local.
  if(cursor.posicion.x >= ancho)then
    cursor.posicion.x := ancho - FontSizeX;
  DrawTextCodepoint(f,cursor.caracter,cursor.posicion,FontSizeY,cursor.color);
end;


//Leer Unicodes, las teclas especiales y de control son ignoradas.
procedure LeerCaracter(var datos:VTchar;var cursor:Tcursor);
var 
  n:integer;
begin
  n := GetCharPressed();
  if(n <> 0)then begin
   datos.cantC:= datos.cantC + 1;
     cursor.indexMaxpos:= datos.cantC + 1;
   //Aumento el array cuando supero el buffer
   if(datos.cantC > buffer)then
      setlength(datos.caracteres,datos.cantC );
     
   datos.caracteres[datos.cantC].unicode := n;
   datos.caracteres[datos.cantC].posicion := cursor.posicion;
   cursor.posicion.x := cursor.posicion.x + FontSizeX;
   cursor.maxpos:= cursor.posicion; //Guarda la poscion maxima, si me muevo de la posicion maxima puedo recuperarla
  end;
    end;

    
//Resetea las posicion x del cursor y aumenta y.
procedure LeerEnter(var posiCursor : TVector2;var maxpos:TVector2);
begin
  if(IsKeyPressed(KEY_ENTER))then begin
    posiCursor.x:= 0;
    posicursor.y:= posicursor.y + FontSizeY;
     //xmaxpos:= posicursor;
  end;
end;




//IndexC para ir obteniendo las posiciones de los caracteres anteriores
procedure moverCursor(var posicursor : TVector2;v:array of Tchar;cantC:integer;
		      var indexCur   : integer; maxPosCur:TVector2);
var
   aux : integer;
begin
   aux:= indexCur; //este auxiliar esta para soluucionar el bus cuando no hay maws caracteres abajo de la linea
   if(indexCur > 0)then
      if(IsKeyDown(KEY_LEFT))then begin
	 indexCur:= indexCur - 1;
	 posicursor:= v[indexCur].posicion;

      end;
   
   if(indexCur < cantC +1)then begin
      if(indexCur < cantC)then begin
	 if(IsKeyDown(KEY_RIGHT))then begin
	 indexCur:= indexCur + 1;
	 posicursor:= v[indexCur].posicion;
      end;
      end
     else if(IsKeyDown(KEY_RIGHT))then begin
	indexCur:= indexCur + 1;
	posicursor:= v[indexCur].posicion;
	posicursor:= maxposcur;
   end;
   end;

   //Esto es horrible, si. Pero por el momento funciona. Eso si No te olvides de cambiarlo.
   if(IsKeyDown(KEY_UP))then begin
      while(cantC <> 0)do begin
      cantC := cantC - 1;
	 if(v[cantC].posicion.x = posicursor.x) and (v[cantC].posicion.y < posicursor.y)then begin
	    posicursor := v[cantC].posicion;
	    indexCur:= cantC;
	    exit();
	 end;
      end
   end;
   //Esto es horrible, si. Pero por el momento funciona. Eso si No te olvides de cambiarlo.
      if(IsKeyPressed(KEY_DOWN))then begin
      while(aux  < cantC)do begin
	 if(v[aux].posicion.x = posicursor.x) and (v[aux].posicion.y > posicursor.y)then begin
	    indexCur:= aux;
	    posicursor := v[indexCur].posicion;
	    exit();
	 end;
	 aux:= aux + 1;
      end
      end
end;

  var
    datos:VTchar;
    f:TFont;
    cursor:TCursor;
begin
  cursor.posicion.x:= 0; cursor.posicion.y:= 0;
   cursor.indexMaxPos:= 1; //Tengo que ver esto, porque ya tengo un contador de caracteres, esta esta siempre 1+ que el contador.
  cursor.caracter:= 9601; cursor.color:= RAYWHITE;
  datos.color:= RAYWHITE;
  //Reserva menoria para el array dinamico
  setlength(datos.caracteres,buffer);
  InitWindow(ancho,alto, 'Torped');
  f:= LoadFontEx('./Font/HackNerdFont-Regular.ttf',round(FontSizeY),nil,9796);
  SetTargetFps(60);
  while not WindowShouldClose() do begin
    BeginDrawing();
    LeerCaracter(datos,cursor);
     LeerEnter(cursor.posicion,cursor.maxpos);
     moverCursor(cursor.posicion,datos.caracteres,datos.cantC,
		 cursor.indexmaxpos,cursor.maxpos);
    rederizarCaracteres(f,datos,cursor);
    ClearBackground(black);
    EndDrawing();
  end;
  CloseWindow();
  end.
