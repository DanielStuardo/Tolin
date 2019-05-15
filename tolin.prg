#include "memoedit.ch"

REQUEST HB_LANG_ES
HB_LANGSELECT( "ES" )
REQUEST HB_CODEPAGE_UTF8
hb_cdpSelect( "UTF8" )

function main()

public _CR:=HB_OSNewline()
public lini:=0
public lfin:=0
public STRING
public BUFFER:={}

numParam:=PCOUNT()

SETCANCEL(.T.)
SET SCOREBOARD OFF
SET ESCAPE ON
SET DATE FRENCH
SET CENTURY ON

/* REVISA PARAMETROS */

inputFile:=""  // archivo de entrada
_file:=""      // archivo de macros

if numParam>0
   _arr_par:=array(numParam)
   iParam:=1
   //  rellenar array de parametros para distribuir despues de la carga de variables
   WHILE iParam<=numParam
      _arr_par[iParam]:=hb_pValue(iParam)
   //   outstd( "PARAM "+str(iParam)+" = ")
   //   outstd(_arr_par[iParam])
   //   outstd(_CR) 
      ++iParam
   END
//elseif numParam==1
//   _file:=hb_pValue(1)
//   outstd ("PARAM = "+_file+_CR)
   
else
   outstd(_CR+"Modo de uso:"+_CR+_CR+"  tolin [-iehsSOEHT] -f [path]file <-t [path]filemacro | 'script-macro'> [> pipe-file]"+_CR;
          +_CR+"Tolin aborta."+_CR)
   quit
end
/********/

/* CONFIGURA EJECUCION */
//if numParam>1
swMacro:=.F.
swInput:=.F.
swMInput:=.F.
swHelp:=.F.
swBinario:=.F.
swPar:=.F.
swImpar:=.F.
swHead:=.F.
swTail:=.F.
nHead:=0
nTail:=0
nIncremento:=1
nHEADVAR:=1
swStat:=.F.
swManual:=.F.
BUFFERLINEA:=256
inputMultiple:={}


   for i:=1 to len(_arr_par)
      STRING:=_arr_par[i]
//      ? STRING
      if STRING=="-i"      // desde linea
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-i' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         lini:=val(_arr_par[++i])
         if lini<=0
            lini:=1
         end
      
      elseif STRING=="-h"   // help
         swHelp:=.T.
      elseif STRING=="-e"   // hasta linea
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-e' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         lfin:=val(_arr_par[++i])
         if lfin<=0
            lfin:=0
         end
      elseif STRING=="-b"   // fuerza edicion binaria
         swBinario:=.T.
      elseif STRING=="-O"  // odd solo lineas impares
         if swPar
            swPar:=.F.
         end
         swImpar:=.T.
      elseif STRING=="-E"  // even solo lineas pares
         if swImpar
            swImpar:=.F.
         end
         swPar:=.T.
      elseif STRING=="-H"   // solo un encabezado de n líneas
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-H' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         nHead:=val(_arr_par[++i])
         if nHead<=0
            nHead:=0
         end
         if swTail
            swTail:=.F.
         end
         swHead:=.T.
      elseif STRING=="-T"   // solo el final desde n líneas
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-T' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         nTail:=val(_arr_par[++i])
         if nTail<=0
            nTail:=0
         end
         if swHead
            swHead:=.F.
         end
         swTail:=.T.
      elseif STRING=="-S"   // skip numero de linea a saltar luego de la leida.
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-S' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         nIncremento:=val(_arr_par[++i])
      elseif STRING=="-s"   // estadisticas del archivo. recomendado para saber si puede procesarlo.
         swStat:=.T.
      elseif STRING=="-B"    // valor para el BUFFER
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-B' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         buff:=_arr_par[++i]
         tkn:=numtoken(buff," ")
         j:=1
         while j<=tkn
            num:=token(buff," ",j)
            if ISTNUMBER(num)==1
               AADD(BUFFER,val(num))
            elseif ISNOTATION(num)==1
               AADD(BUFFER,e2d(num))
            else
               AADD(BUFFER,num)
            end
            ++j
            tmpBUFFER:=array(len(BUFFER))
            acopy(BUFFER,tmpBUFFER)
            nHEADVAR:=len(BUFFER)+1
         end

      elseif STRING=="-F"  // archivo input multiples
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-F' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         ++i
         while i<=len(_arr_par)
            inputFile:=_arr_par[i]
           // ? "INPUTFILE=[",inputFile,"]"
            if substr(inputFile,1,1)!="-"  // .and. substr(inputFile,1,1)!="'"
               aadd(inputMultiple,inputFile)
            else
               --i
               exit
            end
            ++i
         end
         inputFile:=""
         swMInput:=.T.
         swInput:=.F.
      elseif STRING=="-f"  // archivo input
         if i==len(_arr_par)
            outstd(_CR+"Parametro '-f' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         inputFile:=_arr_par[++i]
         inputMultiple:={}
         aadd(inputMultiple,inputFile)
         swInput:=.T.
         swMInput:=.F.
      elseif STRING=="-" // archivo/script de macros
         if i==len(_arr_par)
            outstd(_CR+"Parametro '"+STRING+"' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         _file:=hb_utf8tostr(_arr_par[++i])
      elseif STRING=="-man"   // manual completo.
         swManual:=.T.    
      elseif STRING=="-t" .or. STRING=="-" // archivo/script de macros
         if i==len(_arr_par)
            outstd(_CR+"Parametro '"+STRING+"' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         _file:=_arr_par[++i]
         swMacro:=.T.
      else                 // asume script en linea.
         _file:=hb_utf8tostr(STRING)
      end
   end
//end

STRING:=""

if swManual

   setcursor(0)
   TLINEA:=MAXROW()
   SLINEA:=MAXCOL()
   cVAR:=hb_utf8tostr(MEMOREAD("tolin.help"))
   MSGTOTAL:="AYUDA DE MACROS - TOLIN  | ^C=Av Pag. ^R=Re Pag. ^N=Search ^K=Next ^J=Before"
   public nRow:=1
   public nColumn:=0
   nPos:={}
   LISTAFOUND:={}
   cBUSCA:=""
   oldBUSCA:=space(30)
   tfound:=0
   nInc:=1
      @ 0,0 CLEAR TO TLINEA-3,MAXCOL()
      @ 1, 1 TO TLINEA-3,MAXCOL()-1 DOUBLE
      setpos(0,2); outstd( MSGTOTAL )
   while .T.

      MSGBARRA("This program is free")
      setcolor( 'GR+/N,N/GR+,,,W/N' )
      while inkey()!=0
         ;
      end
      cVAR:=MEMOEDIT(cVAR,2,2,TLINEA-4,SLINEA-2, .F.,"MemoUDF",,SLINEA,nRow,nColumn)
      c:=inkey()
      if lastkey()==27
         exit
      end
     // ? "LASTKEY=",LASTKEY()
      if c==11
         c:=14; nInc:=1; hb_keyPut(13)
      elseif c==10
         c:=14; nInc:=-1; hb_keyPut(13)
      end
      if c==14
         @ TLINEA-2,0 CLEAR TO TLINEA,SLINEA
         cBUSCA:=oldBUSCA+space(30-len(oldBUSCA))   //space(int(SLINEA/2))
         @TLINEA-1, 2 say "SEARCH? " get cBUSCA pict "@S20"
         read
         cBUSCA:=alltrim(cBUSCA)
     //    ? "CBUSCA = ",cBUSCA; inkey(0)
          
         if len(cBUSCA)>0
            if oldBUSCA!=cBUSCA
            LISTAFOUND:={}
            nOCURR:=NUMAT(cBUSCA,cVAR)
            if nOCURR>0
           //    ? "OCURRENCIAS:",nOCURR
               for j:=1 to nOCURR
                  tmpPos:=ATNUM(cBUSCA,cVAR,j)
             //     ? "POS ",j," = ",tmpPos
                  if tmpPos>0
                     AADD(LISTAFOUND,tmpPos)
                  end 
               end
            end
          //  inkey(0)
            if len(LISTAFOUND)>0
               tFound:=1
               nPos := MPosToLC(cVAR, SLINEA, LISTAFOUND[tFound])
               nRow:=nPos[1]
               nColumn:=nPos[2]
               oldBUSCA:=cBUSCA
            else
               @ TLINEA-1,0 CLEAR TO TLINEA,SLINEA
               @ TLINEA-1,2 say "MATCH NOT FOUND!"
               inkey(0)
            end
            else
            if len(LISTAFOUND)>0
               if nInc>0
                  if tFound==len(LISTAFOUND)
                     tFound:=1
                  else
                     tFound:=tFound+nInc
                  end
               else
                  if tFound==1
                     tFound:=len(LISTAFOUND)
                  else
                     tFound:=tFound+nInc
                  end
               end
               nPos := MPosToLC(cVAR, SLINEA, LISTAFOUND[tFound])
                nRow:=nPos[1]
               nColumn:=nPos[2]
            end
            end
         end
     // elseif c==11  // siguiente palabra
         /*if len(LISTAFOUND)>0
            if tFound==len(LISTAFOUND)
               tFound:=1
            else
               ++tFound
            end
            nPos := MPosToLC(cVAR, SLINEA, LISTAFOUND[tFound])
            nRow:=nPos[1]
            nColumn:=nPos[2]
         end*/
      end
     /* while inkey()==0
         ;
      end */
   end
   setcursor(1)
   clear
   quit
end

if swHelp
//   outstd(hb_utf8tostr("Ayuda Tolin versión alfa")+_CR)
   outstd(hb_utf8tostr("         ,-----.      MMMMM      l")+_CR)
   outstd(hb_utf8tostr("   /\j__/\  (  \`--.    M   OOO  ll   º  N.  N")+_CR)
   outstd(hb_utf8tostr("   \`@_@'/  _)  >--.`.  M  O   O ll   I  N N N")+_CR)
   outstd(hb_utf8tostr("  _{.:Y:_}_{{_,'    ) ) m  O   O ll   Ii N  'n")+_CR)
   outstd(hb_utf8tostr(" {_}`-^{_} ```     (_/  M   OOO   lll Ii n   N  Versión Alfa.")+_CR)
   outstd(_CR+"Modo de uso:"+_CR+"   tolin [-iehsSOEHT] -f [path]file <-t [path]filemacro | 'script-macro'> [> file]"+_CR+_CR)
   outstd(hb_utf8tostr("   -i n        línea inicial de proceso.")+_CR)
   outstd(hb_utf8tostr("   -e n        línea final de proceso.")+_CR)
   outstd(hb_utf8tostr("   -h          esta ayuda.")+_CR)
   outstd(hb_utf8tostr("   -man        manual de funciones y operadores de macros Tolin.")+_CR)
   outstd(hb_utf8tostr("   -s          estadísticas del archivo. Sirve para saber si se podrá procesar con Tolin.")+_CR)
   outstd(hb_utf8tostr("               Esta opción anula todas las demás, excepto '-fb'.")+_CR)
   outstd(hb_utf8tostr("   -S n        número de líneas a saltar luego de procesada una línea (Skip o incremento).")+_CR)
   outstd(hb_utf8tostr("   -O          (Odd)  procesa solo líneas impares. Si el proceso inicia en una línea par, esta es omitida.")+_CR)
   outstd(hb_utf8tostr("   -E          (even) procesa líneas pares. Si el proceso inicia en una línea impar, esta es omitida.")+_CR)
   outstd(hb_utf8tostr("   -H n        procesa las 'n' primeras líneas del archivo. Similar a HEAD de Linux.")+_CR)
   outstd(hb_utf8tostr("   -T n        procesa las 'n' últimas líneas del archivo. Similar a TAIL de Linux.")+_CR)
   outstd(hb_utf8tostr("   -B valor    añade un valor al BUFFER, que puede ser usado por LET y LIN.")+_CR)
   outstd(hb_utf8tostr("               Usar el BUFFER para guardar valores es como usar variables globales. Uselas.")+_CR)   
   outstd(hb_utf8tostr("   -f          indica el archivo a procesar. Puede añadir una ruta.")+_CR)
   outstd(hb_utf8tostr("   -F          procesa un lote de archivos, indicados con comodines. Ejemplo: *.txt.")+_CR)
   outstd(hb_utf8tostr("   -t          indica un archivo de macros.")+_CR)
   outstd(hb_utf8tostr("   -b          fuerza procesamiento sobre archivo binario. Un archivo binario, para Tolin, es aquel que")+_CR)
   outstd(hb_utf8tostr("               contiene carcateres ASCII menores a 32 y distintos a 9, 10 y 13. Si tiene un archivo de datos")+_CR)
   outstd(hb_utf8tostr("               que no debería tener estos caracteres, use '-b' para forzar su proceso.")+_CR)
   outstd(hb_utf8tostr(" [-] 'script'  script de comandos que procesarán el archivo.")+_CR)
   outstd(hb_utf8tostr("               Use el guión '-' antes de 'script' si este viene a continuación del parámetro '-F'.")+_CR)
   outstd(hb_utf8tostr("               Ejemplo:")+_CR)
   outstd(hb_utf8tostr("                    tolin -F *.txt - 'void at{"+chr(34)+"base"+chr(34)+"}?#;' -H 10  /* '-' necesario */")+_CR)
   outstd(hb_utf8tostr("                    tolin -F *.txt -H 10 'void at{"+chr(34)+"base"+chr(34)+"}?#;'    /* '-' no necesario */")+_CR+_CR)
   outstd(hb_utf8tostr("               Los comandos y funciones son los mismos que usa ED4XU, por lo que se puede consultar")+_CR)
   outstd(hb_utf8tostr("               su ayuda para más detalles.")+_CR)
   outstd(hb_utf8tostr("               EXCEPCION: el comando CLEAR, en Tolin, limpia el BUFFER. Además, los comandos SAVE y LOAD")+_CR)
   outstd(hb_utf8tostr("               no tienen uso con Tolin, y el comando FILE, que devuelve el nombre del archivo procesado,")+_CR)
   outstd(hb_utf8tostr("               no existe en ED4XU.")+_CR+_CR)
   outstd(hb_utf8tostr("  OBSERVACIONES.")+_CR)
   outstd(hb_utf8tostr("       Tolin carga y analiza el archivo de entrada antes de procesarlo con los comandos y funciones de")+_CR)
   outstd(hb_utf8tostr("       macros de Edit4Xu. No acepta ser parte del pipeline.")+_CR)
//   outstd(hb_utf8tostr("       Como hace una carga inicial, es posible acceder a líneas que ya fueron procesadas, con LIN(n).")+_CR)
   outstd(hb_utf8tostr("       Otras observaciones son las siguientes:")+_CR+_CR)
   outstd(hb_utf8tostr("           * La salida del proceso será la consola, o un archivo, si redirige la salida con '>',")+_CR)
   outstd(hb_utf8tostr("           * Aparte, puede obtener una salida alternativa usando el BUFFER de Tolin. La función")+_CR)
   outstd(hb_utf8tostr("             COPY copia datos al BUFFER.")+_CR)
   outstd(hb_utf8tostr("           * El BUFFER es guardado al finalizar el proceso, en un archivo que tiene como nombre la")+_CR)
   outstd(hb_utf8tostr("             fecha y la hora actual, más '.buffer'. Por ejemplo, si usted usó el BUFFER para guardar")+_CR)
   outstd(hb_utf8tostr("             datos, el archivo de salida del BUFFER ser :")+_CR)
   outstd(hb_utf8tostr("                     20191201_130435.buffer")+_CR)
   outstd(hb_utf8tostr("           * Las opciones '-ie' son INCOMPATIBLES con '-HT'.")+_CR)
   outstd(hb_utf8tostr("           * La opción '-f' es INCOMPATIBLE con '-F'.")+_CR)
   outstd(hb_utf8tostr("           * Tolin no admite pipeline como datos de entrada. Debe usar '-f'.")+_CR)
   outstd(hb_utf8tostr("           * Por defecto, Tolin lee archivos UTF8 y US-ASCII, y no hace conversión de codepage.")+_CR)
   outstd(hb_utf8tostr("             Sin embargo, hace un esfuerzo. Intente '-s' para saber si su archivo puede ser procesado.")+_CR+_CR)
   outstd(hb_utf8tostr("  EJEMPLOS.")+_CR)
   outstd(hb_utf8tostr("        1) Si un archivo 'nuevo.txt' contiene un caracter anómalo (e.g. #1), el comando:")+_CR+_CR)
   outstd(hb_utf8tostr("                     tolin -f nuevo.txt -b 'void at{ch(1)}?#:tr{ch(1),")+chr(34)+chr(34)+"};'"+_CR+_CR)
   outstd(hb_utf8tostr("           podrá procesarlo, reemplazando #1 por nada. Debe usar '-b'.")+_CR)
   outstd(hb_utf8tostr("           El comando VOID indica que deben incluirse las líneas en blanco en el proceso.")+_CR)
   outstd(hb_utf8tostr("           La función TR reemplaza todo lo que encuentre en la línea.")+_CR)
   outstd(hb_utf8tostr("           La función AT devuelve la posición del primer match, sin importar si es una palabra completa")+_CR)
   outstd(hb_utf8tostr("           o es parte de otra. La función AF busca el match exacto y completo.")+_CR+_CR)
   outstd(hb_utf8tostr("        2) Si 'prog.c' tiene una codificación US-ASCII o ISO-8859xx, es posible que use #10 y #13")+_CR)
   outstd(hb_utf8tostr("           como salto de línea. Para eliminar #13, basta con hacer esto:")+_CR+_CR)
   outstd(hb_utf8tostr("                     tolin -f prog.c 'void #'")+_CR+_CR)
   outstd(hb_utf8tostr("        3) Suponga un programa Harbour donde se haya escrito en duro el caracter flecha (#16), en")+_CR)
   outstd(hb_utf8tostr("           muchas líneas. Para reparar eso, puede usar la siguiente línea:")+_CR+_CR)
   outstd(hb_utf8tostr("                     tolin -f clrsel.prg -b 'void at{ch(16)}?#:tr{("+;
                                              chr(34)+"\"+chr(34)+chr(34)+"+"+;
                                              "ch(16)+"+chr(34)+"\"+chr(34)+chr(34)+;
                                              "),"+chr(34)+"chr(16)"+chr(34)+"};'")+_CR+_CR)
   outstd(hb_utf8tostr("           Aparte de eliminar los #13 sobrantes (propio de codificación US-ASCII), busca el caracter")+_CR)
   outstd(hb_utf8tostr("           anómalo (AT); si no lo encuentra, libera la línea completa. Pero, si lo encuentra, reemplaza")+_CR)
   outstd(hb_utf8tostr("           el caracter "+chr(34)+chr(16)+chr(34)+", por "+chr(34)+"chr(16)"+chr(34)+", la función.")+_CR)
   outstd(hb_utf8tostr("           El caracter de escape '\"+chr(34)+"' se usa para que Tolin pueda reconocer comillas.")+_CR+_CR)
   outstd(hb_utf8tostr("        4) Para conocer la estadística de un grupo de archivos:")+_CR+_CR)   
   outstd(hb_utf8tostr("                     tolin -F datos/*.csv -s")+_CR+_CR)
   outstd(hb_utf8tostr("        5) Para procesar un grupo de archivos. La salida será única, así como los datos almacenados en")+_CR)
   outstd(hb_utf8tostr("           el BUFFER con COPY:")+_CR+_CR)
   outstd(hb_utf8tostr("                     tolin -F datos/*.csv 'void match{"+chr(34)+"CTAAGH"+chr(34)+"}?:{I,{"+chr(34)+;
                                             "  :  "+chr(34)+",#}};'")+_CR+_CR)
   outstd(hb_utf8tostr("           Buscará exactamente 'CTAAGH'; si lo encuentra, despliega la línea con el número de línea.")+_CR)
   outstd(hb_utf8tostr("           Si no lo encuentra, no hace nada (eso quiere decir '?:')")+_CR+_CR)
   outstd(hb_utf8tostr("  AUTOR.")+_CR)
   outstd(hb_utf8tostr("           Don Dalien, mayo de 2019. daniel.stuardo@gmail.com")+_CR)
   outstd(hb_utf8tostr("           Bugs, consultas, al mail.")+_CR+_CR)

   quit
end

/*if len(alltrim(inputFile))==0
   outstd(_CR+"No fue indicado un archivo de entrada"+_CR+"Use '-f input-file'."+_CR+_CR+"Tolin aborta"+_CR)
   quit
end*/

if swInput
   if !file(inputFile)
      outstd(_CR+"No existe el archivo de entrada '"+inputFile+"'"+_CR+_CR+"Tolin aborta"+_CR)
      quit
   end
else
   if swMInput
      for i:=1 to len(inputMultiple)
         if !file(inputMultiple[i])
            outstd(_CR+"No existe el archivo de entrada '"+inputMultiple[i]+"'"+_CR+_CR+"Tolin aborta"+_CR)
            quit
         end
      end
   else
      outstd(_CR+"No fue indicado un archivo de entrada"+_CR+"Use '-f input-file'."+_CR+_CR+"Tolin aborta"+_CR)
      quit
   end
end
if !swStat
   if swMacro
      if !file(_file)
         outstd(_CR+"No existe el archivo de macros '"+_file+"'"+_CR+_CR+"Tolin aborta"+_CR)
         quit
      else  // lo carga
         _file:=memoread(_file)
      end
   else
      if len(alltrim(_file))==0
         outstd(_CR+"No fue indicado un script o archivo de macros"+_CR+"Use '-t macro-file' para usar un archivo de macros."+_CR+_CR+"Tolin aborta"+_CR)
         quit
      end
   end
end

/* VERIFICA SISTEMA OPERATIVO */
OSHost:=OS()
OPERATING_SYSTEM:=upper(alltrim(substr(OSHost,1,at(" ",OSHost))))

/********/

FOR nFile:=1 to len(inputMultiple)

inputFile:=inputMultiple[nFile]

/* VERIFICA TIPO DE ARCHIVO Y OBTIENE DATOS DEL ARCHIVO */
if OPERATING_SYSTEM=="LINUX" 
   EXT:=FUNFSHELL("file -i "+inputFile,3)
elseif OPERATING_SYSTEM=="DARWIN"
   EXT:=FUNFSHELL("file -I "+inputFile,3)
end 
EXT:=STRTRAN(EXT,HB_OSNEWLINE(),"")
EXT:=substr(EXT,at("=",EXT)+1,len(EXT))

swAnomalo:=.F.
swConvert:=.F.
/* LECTURA DEL ARCHIVO */
fp:=fopen(inputFile,0)
if ferror()!=0
   outstd(_CR+"El archivo '"+inputFile+"' no puede abrirse."+CR+CR+"Tolin aborta."+_CR)
   quit
end

oldNUMCAR:=0
oldNL:=0
oldBUFFLINEA:=0
lini:=0
lfin:=0

if EXT!="binary" .or. swBinario

      READFILE:=CUENTALINEAS(inputFile)
      NUMCAR:=READFILE[2]
      NL:=READFILE[1]
      BUFFERLINEA:=READFILE[3]+2  // maxima logitud de linea más 2, por los newline
      if NUMCAR>0 /*.and. BUFFERLINEA==0*/ .and. NL==1
         oldNUMCAR:=NUMCAR
         oldNL:=NL
         oldBUFFLINEA:=BUFFERLINEA
         READFILE:=SPCUENTALINEAS(inputFile)
         NUMCAR:=READFILE[2]
         NL:=READFILE[1]
         BUFFERLINEA:=READFILE[3]+2
         swAnomalo:=.T.
      end
      if NUMCAR>0
         if BUFFERLINEA>0 .and. NL>0
            if EXT=="utf-8" .or. EXT=="us-ascii"
               cBUFF:=HB_UTF8TOSTR(FREADSTR(FP,NUMCAR))
               swConvert:=.T.
            else  //if "iso-8859" $ EXT .or. "unknown-8bit" $ EXT
               cBUFF:=FREADSTR(FP,NUMCAR)
            end
            if swAnomalo
               cBUFF:=strtran(cBUFF,chr(13),chr(10))
            else
               cBUFF:=strtran(cBUFF,chr(13),"")
            end
            NUMCAR:=LEN(cBUFF)
            STRING:=GETLINEAS(cBUFF,NL,NUMCAR,BUFFERLINEA)
         else 
            outstd(_CR+"El archivo '"+inputFile+"' no puede ser procesado por Tolin. Prueba Edit4Xu."+CR+CR+"Tolin aborta."+_CR)
            quit
         end
      else
        outstd(_CR+"El archivo '"+inputFile+"' no puede ser procesado por Tolin. Prueba Edit4Xu."+CR+CR+"Tolin aborta."+_CR)
        quit
      end

else
   outstd(_CR+"El archivo '"+inputFile+"' es binario y no puedo procesarlo. Prueba con '-b'."+_CR+_CR+"Tolin aborta."+_CR)
   quit
end
fclose(fp)

/* VERIFICA SI QUIERE ESTADISTICAS */
if swStat
   outstd(_CR+"Estadisticas del archivo: '"+inputFile+"'"+_CR)
   outstd(_CR+hb_utf8tostr("Tipo      : "+EXT))
   outstd(_CR+hb_utf8tostr("Tamaño    : "+hb_ntos(NUMCAR)+" bytes, "+hb_ntos(NUMCAR/1024)+" KB, "+hb_ntos(NUMCAR/1024/1024)+" MB"))
   outstd(_CR+hb_utf8tostr("Líneas    : "+hb_ntos(NL)))
   outstd(_CR+hb_utf8tostr("Línea más larga : "+hb_ntos(BUFFERLINEA)+" caracteres"))
   
   EXT:=FUNFSHELL("wc "+inputFile,3)
   outstd(_CR+_CR+hb_utf8tostr("Informe reportado por 'wc':"))
   outstd(_CR+hb_utf8tostr("Tamaño    : "+token(EXT," ",3)+" bytes "))
   outstd(_CR+hb_utf8tostr("Líneas    : "+token(EXT," ",1)+" (newlines)"))
   outstd(_CR+hb_utf8tostr("Palabras  : "+token(EXT," ",2)))
   if oldNL>0
   outstd(_CR+_CR+hb_utf8tostr("Archivo original sin forzar lectura:"))
   outstd(_CR+hb_utf8tostr("Tamaño    : "+hb_ntos(oldNUMCAR)+" bytes, "+hb_ntos(oldNUMCAR/1024)+" KB, "+hb_ntos(oldNUMCAR/1024/1024)+" MB"))
   outstd(_CR+hb_utf8tostr("Líneas    : "+hb_ntos(oldNL)))
   outstd(_CR+hb_utf8tostr("Línea más larga : "+hb_ntos(oldBUFFLINEA)+" caracteres"))
   end
   if swConvert
   outstd(_CR+_CR+hb_utf8tostr("Conversión UTF-8? Sí"))
   else
   outstd(_CR+hb_utf8tostr("Conversión UTF-8? No todos los caracteres especiales fueron convertidos."))
   end
//   outstd(_CR+hb_utf8tostr("ASCII nl  :"+hb_ntos(asc(NEWLINE)))+_CR)
   outstd(_CR+hb_utf8tostr("Si el número de líneas o el tamaño no coinciden con el archivo original,")+_CR+;
                           "es posible que no pueda ser procesado.")
   outstd(_CR+hb_utf8tostr("También es posible que 'wc' cuente caracteres sin conversión especial ASCII."))
   outstd(_CR+hb_utf8tostr("Intente mejorarlo con Edit4Xu.")+_CR+_CR)
   loop
end
/*********/

/* VERIFICO RANGO DE PROCESO DE ARCHIVO EN LINEAS */
if lini==0
   lini:=1
end
if lfin==0
   lfin:=NL
elseif lfin>NL
   lfin:=NL
end

/********/

/* COMIENZA EL PROCESO */

/* VERIFICA HEAD */
nAvance:=0
if swHead   // recalibra lfin
   if nHead<lfin
      lfin:=nHead
      lini:=1
   end
elseif swTail
   if NL-nTail>lini
      lini:=NL-nTail
      lfin:=NL
   end
end

/* AVANZA PUNTERO DE ACUERDO A lini */
/*if lini>1
  nAvance:=GETINITFILE(inputFile,lini)
end*/

if lini>lfin
   outstd(_CR+"El parametro '-i' no puede ser mayor que '-e'."+CR+CR+"Tolin aborta."+_CR)
   quit
end

public SWNOTNUL:=.F.
public SWKEEPVACIO:=.F.
public SWNOBUFFER:=.F.
public SWRESET:=.F.

/* LECTURA DEL ARCHIVO */
/*fp:=fopen(inputFile,0)
if ferror()!=0
   outstd(_CR+"El archivo '"+inputFile+"' no puede abrirse"+CR+CR+"Tolin aborta."+_CR)
   quit
end*/
/*if nAvance>0
   fseek(fp,nAvance,0)
end
*/

/*cBUFF:=HB_UTF8TOSTR(FREADSTR(fp,NUMCAR))
NUMCAR:=LEN(cBUFF)
STRING:=GETLINEAS(cBUFF,NL,NUMCAR,BUFFERLINEA)
cBUFF:=""
fclose(fp)*/ 
                  
                  
/* PREPARA SCRIPT */
Q:=_CTRLL_OBTIENELISTA(_file)

if len(Q)==0
   fclose(fp)
   return NIL
end
/*R:={}
T:={}
for i:=1 to len(Q[1])
   AADD(T,Q[1][i])
   AADD(R,Q[2][i])  // esto evaluará si todo sale bien
end
*/
//R:=_CTRLL_EVALUA(T,R)
R:=_CTRLL_EVALUA(Q[1],Q[2])
if valtype(R)=="L"
   fclose(fp)
   return NIL
end

DEFTOKEN:=" "   // token por defecto.

/***********/
//CX:=space(BUFFERLINEA)
////BUFFER:={}
/*? "Hasta aqui"
quit*/
if swPar
   if lini%2!=0
      ++lini
   end
   nIncremento:=2
elseif swImpar
   if lini%2==0
      ++lini
   end
   nIncremento:=2
end

   for i:=lini to lfin step nIncremento
      /* BX:=""
       nSavePos := FSEEK( fp, 0, 1 )
       nNumRead := FREAD( fp, @CX, BUFFERLINEA )
      // BX := substr( CX, 1, nNumRead )
       BX := SUBSTR( CX, 1, at(hb_osnewline(),CX))
       nEol:=len(BX)  // debe contar los caracteres especiales para el FSEEK
       BX := hb_utf8tostr(strtran(BX, hb_osnewline(),""))

       FSEEK( fp, nSavePos + nEol, 0 )  // nEol + 1 
       
       ///PROCESA BX
       RX:=_EVALUA_EXPR(@R,BX,i,@BUFFER)
*/
     //  if swConvert
          RX:=_EVALUA_EXPR(@R,STRING[i],i,@BUFFER,inputFile)
     //  else
     //     RX:=_EVALUA_EXPR(@R,STRING[i],i,@BUFFER)
     //  end
    //   if len(BUFFER)==0
          if valtype(RX)=="L"
             break
          end
          if valtype(RX)=="N"
             IF ABS(RX)>INFINITY().or. (ABS(RX)>0.and.ABS(RX)<0.000000000001)
                RX:=alltrim(str(D2E(RX,5)))
             else
                RX:=alltrim(str(RX))
             end
             //outstd(RX+_CR)
             fwrite(1,RX+_CR)
          else
             if len(RX)>0
                //outstd(RX+_CR)
                fwrite(1,hb_strtoutf8(RX)+_CR)
             else
                if SWKEEPVACIO
                   //outstd(_CR)
                   fwrite(1,_CR)
                end
             end
          end
    //   else  // imprime el BUFFER
    //      outstd(BUFFER[1]+_CR)
    //      BUFFER:={}
    //   end
   end
   CX=""
   if SWRESET
      if len(BUFFER)>=nHEADVAR
         tARCHIVO:=substr(inputFile,rat("/",inputFile)+1,len(inputFile))+".buffer"   //strtran(dtoc(date()),"/","")+"_"+strtran(time(),":","")+".buffer"
         if !SAVEFILE(BUFFER,tARCHIVO,LEN(BUFFER),nHEADVAR)
            _ERROR("NO FUE POSIBLE GUARDAR EL CONTENIDO DEL BUFFER")
            quit
         end
      end
      if nHEADVAR>1   // reset el buffer
         BUFFER:=array(len(tmpBUFFER))
         acopy(tmpBUFFER,BUFFER)   // vuelve a los valores originales
      else
         BUFFER:={}
      end
   end

/*********/
//fclose(fp)

END  // for

/* VERIFICO si BUFFER tiene algo que guardar */
if !SWRESET
   if len(BUFFER)>=nHEADVAR
      tARCHIVO:=strtran(dtoc(date()),"/","")+"_"+strtran(time(),":","")+".buffer"
      if !SAVEFILE(BUFFER,tARCHIVO,LEN(BUFFER),nHEADVAR)
         _ERROR("NO FUE POSIBLE GUARDAR EL CONTENIDO DEL BUFFER")
         quit
      end
 /*     if nHEADVAR>1   // reset el buffer
         BUFFER:=array(len(tmpBUFFER))
         acopy(tmpBUFFER,BUFFER)
      else
         BUFFER:={}
      end */
   end
end

return NIL

/** funciones Harbour **/
FUNCTION MemoUDF( nMode, nLine, nCol )
LOCAL nKey := LASTKEY(),i,j,c
LOCAL nRetVal := ME_DEFAULT // Default return action

if nKey==14   // ctrl-n
    hb_keyPut(23)
    hb_keyPut(14)
    nRow:=nLine
    nColumn:=nCol
    nRetVal := ME_IDLE
elseif nKey==11  // ctrl-k
    hb_keyPut(23)
    hb_keyPut(11)
    nRetVal := ME_IDLE
elseif nKey==10  // ctrl-j
    hb_keyPut(23)
    hb_keyPut(10)
    nRetVal := ME_IDLE
end

RETURN nRetVal 

PROCEDURE MSGBARRA(MSG)
//SETCOLOR(N2COLOR(cBARRA))
   TLINEA:=MAXROW()
   SLINEA:=MAXCOL()
@ TLINEA-2,0 CLEAR TO TLINEA,MAXCOL()
setpos(TLINEA-1,int(SLINEA/2)-INT(LEN(MSG)/2));outstd(iif(len(MSG)>SLINEA, substr(MSG,1,SLINEA-1),MSG))
setpos(TLINEA  ,int(SLINEA/2)-14);outstd("(Press ESC to continue...)")
RETURN


FUNCTION SAVEFILE(TEXTO,ARCHIVO,TOPE,nHEADVAR)
LOCAL I,FP,STRING,J,LIN,EXT

  IF (FP:=FCREATE(ARCHIVO))==0
     RETURN .F.
  END
  LIN:=0
  FOR I:=nHEADVAR TO TOPE
     if valtype(TEXTO[I])=="C"
        STRING:=hb_strtoutf8(TEXTO[I])+_CR
     else
        STRING:=alltrim(str(TEXTO[I]))+_CR
     end
     FWRITE(FP,STRING,LEN(STRING))
     ++LIN
  END
  FCLOSE(FP) 

RETURN .T.

FUNCTION _CTRLL_OBTIENELISTA(DX)
LOCAL Q,i,j,c,fun,ctap:=0,num,R,str,long,k,cTMP,sw,tmpi:=0,ctmpi:=0,ctpar:=0,strfun:=""
Q:={}  // pila de evaluacion
R:={}  // pila de valores

/* saco los comentarios */
cTMP:=""
i:=1
while i<=len(DX)
   c:=substr(DX,i,1)
   
   if c=="/"
      ++i
      c:=substr(DX,i,1)
      if c=="*"
         ++i
         while i<=len(DX)
            c:=substr(DX,i,1)
            if c=="*"
               if (c:=substr(DX,++i,1))=="/"
                  c:=""
                  exit
               end
            end
            ++i
         end
      else
         --i
         c:=substr(DX,i,1)
      end
   elseif c==chr(34)
      cTMP+=c
      ++i
      while i<=len(DX)
         c:=substr(DX,i,1)
         cTMP+=c
         if c==chr(34)
            exit
         end
         ++i
      end
      ++i; loop
   end
   cTMP+=c
   ++i
end

//? cTMP ; inkey(0)
DX:=cTMP
cTMP:=""

/* algunos reemplazos necesarios */
if "null" $ DX   // iteración no cancela con líneas nulas
   SWNOTNUL:=.T.
   DX:=strtran(DX,"null","")
end
if "keep" $ DX    // mantiene el resultado en el buffer, eliminando los datos originales.
   SWRECBUFFER:=.F.
   DX:=strtran(DX,"keep","")
end
if "void" $ DX
   SWKEEPVACIO:=.T.
   DX:=strtran(DX,"void","")
end
if "nobuff" $ DX
   SWNOBUFFER:=.T.
   DX:=strtran(DX,"nobuff","")
end
if "reset" $ DX
   SWRESET:=.T.
   DX:=strtran(DX,"reset","")
end

////DX:=strtran(DX,"?(","IF(")
DX:=strtran(DX,"match{","MATCH(#,")
//DX:=strtran(DX,"(--","(")
DX:=strtran(DX,"(-","(0-")  // ajusto negativos
//DX:=strtran(DX,"(++","INC(")
DX:=strtran(DX,"ins{","INS(#,")
DX:=strtran(DX,"range{","RANGE(#,") 
DX:=strtran(DX,"#{","LIN(")  // linea
DX:=strtran(DX,"tre{","TRE(#,")
DX:=strtran(DX,"(&","VAL(")
DX:=strtran(DX,"($","STR(")
//DX:=strtran(DX,"{","CH(")  // chr
//DX:=strtran(DX,"&{","ASC(")  // asc
DX:=strtran(DX,"{*","CP(#,")
DX:=strtran(DX,"rp{","RP(#,")
DX:=strtran(DX,"{+","PTRP(#,")  // avanza puntero del string
DX:=strtran(DX,"{-","PTRM(#,")  // retorcede puntero extremo de string
DX:=strtran(DX,"mon{","MON(#,")
DX:=strtran(DX,"${","TK(#,")
DX:=strtran(DX,"round{","ROUND(#,")
DX:=strtran(DX,"sub{","SUB(#,")
DX:=strtran(DX,"tr{","TR(#,")
DX:=strtran(DX,"rpc{","RPC(#,")
DX:=strtran(DX,"pc{","PC(#,")
DX:=strtran(DX,"pr{","PR(#,")
DX:=strtran(DX,"pl{","PL(#,")
DX:=strtran(DX,"msk{","MSK(#,")
DX:=strtran(DX,"sat{","SAT(#,")
DX:=strtran(DX,"rat{","RAT(#,")
DX:=strtran(DX,"at{","AT(#,")
DX:=strtran(DX,"af{","AF(#,")
DX:=strtran(DX,"dc{","DC(#,")
DX:=strtran(DX,"one{","ONE(#,")
DX:=strtran(DX,"letk{","LETK(#,")
///? DX; inkey(0)
/**/
i:=1
long:=LEN(DX)
while i <= long
   c:=substr(DX,i,1)
   if c==" "
      ++i
      loop
   end
   if c=="(" 
      AADD(Q,c)
      AADD(R,c)
      ++ctap
   elseif  c==")"
      AADD(Q,c)
      AADD(R,c)
      --ctap
      if ctap<0
         _ERROR("CONV: PARENTESIS DESBALANCEADOS")
         RETURN {}
      end
   elseif c==">"
      c+=substr(DX,++i,1)
      if c==">>"   // desplazamiento derecha
         AADD(Q,c)
         AADD(R,c)
      else
         _ERROR("CONV: SIMBOLO NO RECONOCIDO "+c)
         RETURN {}
      end
   elseif c=="<"
      c+=substr(DX,++i,1)
      if c=="<<"   // desplazamiento izquierda
         AADD(Q,c)
         AADD(R,c)
      else
         _ERROR("CONV: SIMBOLO NO RECONOCIDO "+c)
         RETURN {}
      end
   elseif c==chr(126)   // not
//      AADD(Q,"FNA"); AADD(R,"FNA")
//      AADD(Q,"("); AADD(R,"(")
//      AADD(Q,")"); AADD(R,")")
      AADD(Q,c)
      AADD(R,c)
   
   elseif c=="?"   // un IF má seguro y eficiente.  exp? expr-1 [: expr-2] . Salta hasta ":"
      AADD(Q,"JNZ"); AADD(R,"JNZ")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")
/*      AADD(Q,"FNB"); AADD(R,"FNB")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")") 
  */    
   elseif c==":"    // else
      AADD(Q,"ELSE"); AADD(R,"ELSE")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")
 /*     AADD(Q,"FNB"); AADD(R,"FNB")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")") 
   */
   elseif c==";" .or. c=="."  // endif
      AADD(Q,"ENDIF"); AADD(R,"ENDIF")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")
 /*     AADD(Q,"FNB"); AADD(R,"FNB")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")") 
   */   
   elseif c=="#"   // puede ser numero de línea si es acompañado de un numero #1, #3...
      ++i
      
      num:=""
      while i<=long
         c:=substr(DX,i,1)
         if isdigit(c)
            num+=c
            ++i
         else
            --i
            exit
         end
      end
      if len(num)==0  // es un parámetro
         AADD(Q,"N")
         AADD(R,"#")
/*      elseif num=="I"   // es linea con variable de numero de linea
         AADD(Q,"I"); AADD(R,"I")  // NO, porque #n requiere constante. Si apunto a otra linea, me basta con #{I+10}, por ejemplo,
         AADD(Q,"("); AADD(R,"(")  // para apuntar a otra línea con la cual operar.
         AADD(Q,")"); AADD(R,")")         */
      else
         if ISTNUMBER(num)!=1
            _ERROR("CONV: NUMERO DE LINEA NO VALIDO #<<"+num+">>")
            RETURN {}
         end
         AADD(Q,"LIN"); AADD(R,"LIN")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,"N");  AADD(R,val(num))
         AADD(Q,")"); AADD(R,")")
 /*        AADD(Q,"FNI"); AADD(R,"FNI")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      end
   elseif c=="$"   // puede ser un token del tipo AWK $1, $2,...$n
      ++i
      num:=""
      while i<=long
         c:=substr(DX,i,1)
         if isdigit(c)
            num+=c
            ++i
         else
            --i
            exit
         end
      end
      if ISTNUMBER(num)!=1 .or. len(num)==0
         _ERROR("CONV: NUMERO DE TOKEN NO VALIDO #<<"+num+">>")
         RETURN {}
      end
      AADD(Q,"TK"); AADD(R,"TK")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,"N");  AADD(R,"#")
      AADD(Q,"N");  AADD(R,val(num))
      AADD(Q,")"); AADD(R,")")
/*      AADD(Q,"FNF"); AADD(R,"FNF")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")") */
   elseif c=="@"    // variable de registro.
      tmpi:=i-1  // por si es una asignación
      ++i
      num:=""
      while i<=long
         c:=substr(DX,i,1)
         if c==" "
            ++i
            loop
         end
         if isdigit(c)
            num+=c
            ++i
         else
            --i
            exit
         end
      end
      if ISTNUMBER(num)!=1 .or. len(num)==0
         _ERROR("CONV: NUMERO DE REGISTRO NO VALIDO #<<"+num+">>")
         RETURN {}
      end
      if c=="("   // es una asignación
         // busco hasta donde asigna:
         ctmpi:=i
         strfun:=""
         i+=2  // para saltarme primer "("
         ctpar:=1
         while i<=long
            c:=substr(DX,i,1)
            strfun+=c
            if c=="("
               ++ctpar
            elseif c==")"
               --ctpar
               if ctpar==0
                  exit
               end
               if ctpar<0
                  _ERROR("CONV: PARENTESIS DESBALANCEADOS")
                  RETURN {}
               end
            end
            ++i
         end
         DX:=substr(DX,1,tmpi)+"MOV("+num+","+strfun+substr(DX,++i,len(DX))
         long:=LEN(DX)
         i:=tmpi  // restauro indice para que lea "MOV"
       //  ? "DX?=", DX; inkey(0)
      else
         AADD(Q,"VAR"); AADD(R,"VAR")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,"N");  AADD(R,val(num))
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNA"); AADD(R,"FNA")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      end
   elseif c=='"'   // es un string. para rep() y cat()
      AADD(Q,"C")
      //str:='"'
      str:=""
      ++i
      while i<=LEN(DX)
         c:=substr(DX,i,1)
         if c=='"'
            //str+='"'
            exit
         elseif c=="\"
            ++i
            c:=substr(DX,i,1)
            if c=='"'
               str+='"'
            else
               str+="\"
               --i
            end
         else
            str+=c
         end
         ++i
      end
      if i>LEN(DX)
         _ERROR("CONV: CADENA NO HA SIDO CERRADA")
         RETURN {}
      end

      AADD(R,str+chr(0))
   
   elseif c=="0"   // podría se un número en base distinta: deben ser escritos con mayúscula si son hexas.
     num:=c
     AADD(Q,"N")
     c:=substr(DX,++i,1)
     if c=="x"   // es un numero con base!
        num:=""
        while i<=LEN(DX)
           c:=substr(DX,++i,1)
           if isdigit(c) .or. c=="A".or.c=="B".or.c=="C".or.c=="D".or.c=="E".or.c=="F"
              num+=c
           else
              exit
           end
        end
     //   ? "NUM=",num; inkey(0)
        if c=="b"     // es binairo
           for j:=1 to len(num)
              xt:=substr(num,j,1)
              if xt!="0" .and. xt!="1"
                 _ERROR("CONV: NUMERO BINARIO MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=BINTODEC(num)
        elseif c=="o"   // es octal
           for j:=1 to len(num)
              xt:=substr(num,j,1)
              if !(xt $ "01234567")
                 _ERROR("CONV: NUMERO OCTAL MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=OCTALTODEC(num)
        elseif c=="h"    // es hexadecimal
           for j:=1 to len(num)
              xt:=substr(num,j,1)
              if !(xt $ "0123456789ABCDEF")
                 _ERROR("CONV: NUMERO HEXADECIMAL MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=HEXATODEC(num)
        else   // no es ninguna hueá: error!
           _ERROR("CONV: BASE NUMERICA NO RECONOCIDA: "+num)
           RETURN {}
        end 
   //     ? "NUM=",num; inkey(0)
        AADD(R,num)
        
      else  // es un número que comienza con 0...

        while i<=LEN(DX)
           c:=substr(DX,i,1)
           if isdigit(c) .or. c=="."
              num+=c
           elseif upper(c)=="E"
              num+="E"
              ++i
              c:=substr(DX,i,1)
              if c=="+" .or. c=="-"
                 num+=c
              elseif isdigit(c)
                 num+=c
              else
                 _ERROR("CONV: NO ES UN NUMERO NOTACION-CIENTIFICA VALIDO: "+num)
                 RETURN {}
              end
           else
              --i  // ajusto para que sea leido luego
              exit
           end
           ++i
        end
        if ISNOTATION(num)==1
           AADD(R,E2D(num))
        else
           if ISTNUMBER(num)!=1 .or. !isdigit(substr(num,len(num),1))
              _ERROR("CONV: NO ES UN NUMERO VALIDO: "+num)
              RETURN {}  // error
           else
              AADD(R,val(num))
           end
        end
      end
      
   elseif isdigit(c)
      num:=c
      ++i
      AADD(Q,"N")
    //  ? "EXPR=",DX,len(DX)
      while i<=LEN(DX)
         c:=substr(DX,i,1)
         if isdigit(c) .or. c=="."
            num+=c
         elseif upper(c)=="E"
            num+="E"
            ++i
            c:=substr(DX,i,1)
      //      ? "NUM=",num,"  C=",c; inkey(0)
            if c=="+" .or. c=="-"
               num+=c
            elseif isdigit(c)
               num+=c
            else
               _ERROR("CONV: NO ES UN NUMERO NOTACION-CIENTIFICA VALIDO: "+num)
               RETURN {}
            end
         else
            --i  // ajusto para que sea leido luego
            exit
         end
         ++i
      //   ? num; ??"-->",i ; inkey(0)
      end
      //   ? num; inkey(0)
      // evaluar el número
      if ISNOTATION(num)==1
         AADD(R,E2D(num))
      else
         if ISTNUMBER(num)!=1 .or. !isdigit(substr(num,len(num),1))
            _ERROR("CONV: NO ES UN NUMERO VALIDO: "+num)
            RETURN {}  // error
         else
            AADD(R,val(num))
         end
      end

   elseif isalpha(c) .or. c==chr(126)
      fun:=c
      ++i
      c:=substr(DX,i,1)
      while isalpha(c) .and. i<=LEN(DX)
         fun+=c
         ++i
         c:=substr(DX,i,1)
         if c=="8" .and. upper(fun)=="UTF"
            fun+=c
            ++i  // para el --i del fondo.
         end
      end
      fun:=upper(fun)
      if fun=="PI"
         AADD(Q,"N")
         AADD(R,PI)
      elseif fun=="I"
         AADD(Q,"I"); AADD(R,"I")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNA"); AADD(R,"FNA")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      elseif fun=="POOL"
         AADD(Q,"POOL"); AADD(R,"POOL")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNC"); AADD(R,"FNC")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      elseif fun=="FILE"   // entrega nombre de archivo actual
         AADD(Q,"FILE"); AADD(R,"FILE")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="NT"   // total de tokens
         AADD(Q,"NT"); AADD(R,"NT")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNA"); AADD(R,"FNA")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
       ///  ? "ENCONTRO NT"; inkey(0)
      elseif fun=="CLEAR"
         AADD(Q,"CLEAR"); AADD(R,"CLEAR")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="NOP"
         AADD(Q,"NOP"); AADD(R,"NOP")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNK"); AADD(R,"FNK")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      else
         AADD(Q,fun)
         AADD(R,fun)
/*         ndx:=ASCAN(DICC,fun)
         AADD(Q,cFUN[ndx]); AADD(R,cFUN[ndx])
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      end
      if i<=LEN(DX)
         --i
      end
   elseif c=="}" .or. c=="]"
      AADD(Q,")")
      AADD(R,")")
      --ctap
   elseif c=="{"
      AADD(Q,"CAT")
      AADD(R,"CAT")
      DX:=substr(DX,1,i)+"("+substr(DX,i+1,len(DX))
      long:=LEN(DX)
   elseif c=="["
      AADD(Q,"INT")
      AADD(R,"INT")
      DX:=substr(DX,1,i)+"("+substr(DX,i+1,len(DX))
      long:=LEN(DX)
   elseif c=="+" .or. c=="-" .or. c=="*" .or. c=="/" .or. c=="^".or.c=="%".or.c=="\".or.c=="&".or.c=="|".or.c=="!"
      AADD(Q,c)
      AADD(R,c)
   end
   ++i
end

if /*Q[len(Q)]!=")" .and. Q[LEN(Q)]!="N" .or.*/ ctap!=0
   _ERROR("CONV: PARENTESIS DESBALANCEADOS")
   RETURN {}
end
RETURN {Q,R}

FUNCTION _CTRLL_EVALUA(q,r)
LOCAL pila,pila2,p,p2,sw,l,l2,m,m2,swv,j,DICC,cFUN

/* codigo de funcion */

cFUN:={"FNA","FNA","FNA","FNA","FNA",;
       "FNB","FNB","FNB",;
       "FNC","FNC","FNC","FNC","FNC",;
       "FND","FND","FND","FND","FND","FND",;
       "FNE","FNE","FNE","FNE","FNE","FNE",;
       "FNF","FNF","FNF","FNF","FNF",;
       "FNG","FNG","FNG","FNG","FNG","FNG",;
       "FNH","FNH","FNH","FNH","FNH",;
       "FNI","FNI","FNI","FNI","FNI","FNI","FNI","FNI",;
       "FNJ","FNJ","FNJ","FNJ","FNJ","FNJ","FNJ","FNJ",;
       "FNK","FNK","FNK","FNK",;
       "FNL","FNL","FNL","FNL","FNL","FNL","FNL","FNL",;
       "FNM","FNM","FNM","FNM","FNM","FNM","FNM",;
       "FNN","FNN","FNN","FNN","FNN","FNN"}

DICC:={"NT","I","VAR","MOV","~",;   // A
       "JNZ","ELSE","ENDIF",;   // B
       "POOL","LOOP","ROUND","UTF8","ANSI",;           // C
       "CAT","MATCH","LEN","SUB","AT","RANGE",;  // D
       "AF","RAT","PTRP","PTRM","CP","TR",;  // E
       "TK","LETK","LET","COPY","FILE",;    // F     
       "RP","TRI","LTRI","RTRI","UP","LO",;    // G
       "TRE","INS","DC","RPC","ONE",;       // H
       "VAL","STR","CH","ASC","LIN","PC","PL","PR",;    // I
       "MSK","MON","SAT","DEFT","IF","IFLE","IFGE","CLEAR",; // J
       "NOP","AND","OR","XOR",;    // K
       "NOT","BIT","ON","OFF","BIN","HEX","DEC","OCT",; // L
       "LN","LOG","SQRT","ABS","INT","CEIL","EXP",;  // M
       "FLOOR","SGN","SIN","COS","TAN","INV"}       // N
       
/*   */


pila:={}; pila2:={}
p:={}; p2:={}
aadd(pila,"(")
aadd(pila2,"(")
   while len(q)>0
      sw:=.F.
      l:=alltrim(SDC(q))
      l2:=SDC(r)
      
    //  ? "EVAL : L= ",l,"  L2= ",l2 ; inkey(0)
      
      if l=="N" .or. l=="C"
         aadd(p,l)
         aadd(p2,l2)
      else
         if !es_simbolo(l)
////            ? l ; inkey(0)
            if es_funcion(l)
               aadd(pila,l)     // es funcion
               aadd(pila2,l2)
            else
               _ERROR("SINTAXIS(1): SIMBOLO NO RECONOCIDO ("+l+")") //substr(l,2,len(l))+")")
               RETURN .F.
            end
         else
            if l=="("
               aadd(pila,l)
               aadd(pila2,l2)
            elseif l $ "+*-/^%\&|!>><<" .or. es_funcion(l)
               while !sw
                  m:=SDP(pila)
                  m2:=SDP(pila2)
                  if m=="("
                    aadd(pila,m)  //mete m en pila
                    aadd(pila,l)  //mete l en pila
                    aadd(pila2,m2)
                    aadd(pila2,l2)
                    sw:=.T.; loop //break  //
                    //exit
                  end
                  if l=="^"
                    if m=="^"
                       aadd(p,m)  //mete m en p
                       aadd(p,l)
                       aadd(p2,m2)
                       aadd(p2,l2)
                    else
                       aadd(pila,m) //mete m en pila
                       aadd(pila,l) //mete l en pila
                       aadd(pila2,m2)
                       aadd(pila2,l2)
                       sw:=.T.
                    end

              
                  elseif l=="*" 
                    if m =="^" .or. m=="*" .or. m=="/" .or. m=="%" .or. m=="\"
                       aadd(p,m)   //mete m en p
                       aadd(p2,m2)
                    else
                       if es_funcion(m)
                          aadd(p,m)
                          aadd(p2,m2)
                     /******/
                       else   // ojo: esto falta
                          aadd(pila,m) //mete l en pila
                          aadd(pila2,m2)
                       end    // hasta aquí: esto estaba en XU.
                     /******/
                       aadd(pila,l) //mete l en pila
                       aadd(pila2,l2)
                       sw:=.T.
                    end

                  elseif l=="/" .or. l=="\" .or. l=="%"
                    if m=="*".or.m=="^".or.m=="/" .or. m=="%" .or. m=="\"
                       aadd(p,m)     //mete l en p
                       aadd(pila,l) //mete m en pila
                       aadd(p2,m2)
                       aadd(pila2,l2)
                       sw:=.T.
                    else
                       if es_funcion(m)
                          aadd(p,m)
                          aadd(p2,m2)
                     /******/
                       else   // ojo: esto falta
                          aadd(pila,m) //mete l en pila
                          aadd(pila2,m2)
                     /******/
                       end
                       aadd(pila,l) //mete l en pila
                       aadd(pila2,l2)
                       sw:=.T.
                    end
                
                  elseif l=="+" .or. l=="-" .or. l==">>" .or. l=="<<" .or. l=="&".or.l=="|".or. l=="!"
                     aadd(p,m)       //mete m en p
                     aadd(pila,l)    //mete l en pila
                     aadd(p2,m2)
                     aadd(pila2,l2)
                     sw:=.T.
      
               // -------  Y si es funcion?
                  else
                     if es_funcion(l)
                        aadd(pila,m)
                        aadd(p,l)
                        aadd(pila2,m2)
                        aadd(p2,l2)
                  
                        sw:=.T.
                     end
               // -------------------------
                  end
               end   // while

               if len(pila)==0 
                  aadd(pila,"(")   //mete cen en pila
                  aadd(pila2,"(")
               end
            elseif l==")"          // es un parentesis derecho?
               m:=SDP(pila)        // extrae de pila para m
               m2:=SDP(pila2)
//               ? "M==",m
               while m!="(" 
                  aadd(p,m)        //mete m en p
                  aadd(p2,m2)
                  m:=SDP(pila)     // extrae de pila para m
                  m2:=SDP(pila2)
                  //?? m
                  if m==nil
                      _ERROR("SINTAXIS(2): EXPRESION MAL FORMADA")
                      RETURN .F.
                  end
               end
               if len(pila)>0
                  m:=SDP(pila)
                  m2:=SDP(pila2)
//                  ?"M===",m
                  if es_funcion(m)
                     aadd(p,m)
                     aadd(p2,m2)
                  /*******/
                  else
                     aadd(pila,m) //mete l en pila
                     aadd(pila2,m2)
                  /*******/  
                  end
               end
            end

         end
      end
   end
   if len(pila)>0
      m:=SDP(pila)
      m2:=SDP(pila2)
      while m!="(" .and. m!=NIL
         aadd(p,m)
         aadd(p2,m2)
         m:=SDP(pila)
         m2:=SDP(pila2)
      end
     /* if len(pila)>0 .or. m==NIL
         _ERROR("SINTAXIS(3): EXPRESION MAL FORMADA (QUEDAN "+hb_ntos(len(pila))+" RESULTADOS EN PILA).")
         RETURN .F.
      end */
   end
   // revisa sintacticamente todo.
   pila:={}
/*   for i:=1 to len(p2)
      ?? p2[i],", "
   end
   inkey(0) 
*/
   while !empty(p)
      m:=SDC(p)
   //   ? "P = ",m; inkey(0)
      if m=="N" .or. m=="C" 
         aadd(pila,m)

      elseif m $ "+*-/^%\&|!<<>>"
         o:=SDP(pila)
         n:=SDP(pila)
         if o==NIL .or. n==NIL // .or. o!="N" .or. n!="N" .and. (n!="X" .and. o!="X")
            _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA/TIPO DE OPERANDO OP: ( "+m+" )")
            RETURN .F.
         else
            aadd(pila,"N")
         end
      elseif es_funcion(m)
         if substr(m,1,2)=="FN"  // no tiene que evaluar esto.
            loop
         end
         if m=="ROUND"
            m:=SDP(pila)
            n:=SDP(pila)
            if m==NIL .or. n==NIL ///.or. n!="N" .or. m!="N" .and. (n!="X" .and. m!="X")
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA/TIPO DE ARGUMENTO (ROUND)")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         elseif m=="MON"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            m:=SDP(pila)
            if h==NIL .or. n==NIL .or. o==NIL .or. m==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO (MON)")
               RETURN .F.
            end
            aadd(pila,"C")
         elseif m=="SUB".or.m=="TR" .or. m=="INS" .or. m=="TRE" .or. m=="RPC".or. m=="IF".or. m=="IFLE".or.;
                m=="IFGE" .or.m=="LETK"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if h==NIL .or. n==NIL .or. o==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
         elseif m=="RANGE"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if h==NIL .or. n==NIL .or. o==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         elseif m=="TK"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         elseif m=="CAT" .or. m=="CP".or.m=="RP".or.m=="PTRP".or.m=="PTRM" .or. m=="ONE";
                .or. m=="PL".or.m=="PC".or.m=="PR".or.m=="MSK".or.m=="SAT" .or.m=="DC"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"C")
            end
         elseif m=="AT" .or. m=="AF".or. m=="MATCH" .or. m=="AND" .or. m=="OR".or.m=="XOR".or.m=="RAT".or.;
                m=="BIT".or.m=="ON".or.m=="OFF"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         elseif m=="UP".or.m=="LO".or.m=="TRI".or.m=="LTRI".or.m=="RTRI".or.m=="BIN".or.m=="HEX".or.m=="UTF8".or.m=="ANSI"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
         elseif m=="SAVE"
            m:=SDP(pila)
            if m==NIL
               _ERROR("SINTAXIS: ESPERO UN NOMBRE DE ARCHIVO (SAVE)")
               RETURN .F.
            end
  ///          aadd(pila,"C") // solo para que pase el analisis
         elseif m=="LET" .or. m=="MOV"
            h:=SDP(pila)
            n:=SDP(pila)
            if h==NIL .or. n==NIL
               _ERROR("SINTAXIS: FALTAN ARGUMENTOS EN "+m)
               RETURN .F.
            end
         
         elseif m=="LOAD" .or. m=="SAVE"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: ESPERO UN NOMBRE DE ARCHIVO ("+m+")")
               RETURN .F.
            end
         elseif m=="DEFT" .or. m=="LOOP"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: ESPERO UN ARGUMENTO VALIDO PARA ("+m+")")
               RETURN .F.
            end
         
         elseif m=="POOL" .or. m=="CLEAR" .or. m=="JNZ" .or. m=="ELSE" .or. m=="ENDIF"
            ;
            
         elseif m=="CH" .or. m=="STR"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: ESPERO UN ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C") // solo para que pase el analisis
         elseif m=="LEN".or. m=="ASC" /*.or. m=="INC"*/.or.m=="DEC" .or. m=="VAR" .or. m=="NOT"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         
         elseif m=="VAL"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         elseif m=="NOP"  .or. m=="FILE"
            aadd(pila,"C")

         elseif m=="COPY"
            n:=SDP(pila)
            if n==NIL
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
           
            
         elseif m=="I" .or. m=="NT"
            aadd(pila,"N")
         else
            m:=SDP(pila)
            if m==NIL //.or. m!="N"
               _ERROR("SINTAXIS: EXPRESION MAL FORMADA. FALTA ARGUMENTO O TIPO DISTINTO")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         end
      else  // puede ser variable
         _ERROR("SINTAXIS: SIMBOLO NO RECONOCIDO ("+m+")")
         RETURN .F.
      end
   end
   
/* Añade codigos de funcion */
   
   i:=1 
   while i<=len(p2)
      _pos:=ascan(DICC,p2[i])
      if _pos>0
         asize(p2,len(p2)+1)

         ains(p2,i)
         p2[i]:=cFUN[_pos]
 /*      ?
       for j:=1 to len(p2)
        ?? p2[j],", "
       end
       ?*/
         ++i
      end
      ++i
   end 


/*   for i:=1 to len(p2)
      ?? p2[i],", "
   end
   inkey(0) */
  /* if len(pila)>1
      _ERROR("SINTAXIS: EXPRESION MAL FORMADA (QUEDAN "+hb_ntos(len(pila))+" RESULTADOS EN PILA).")
      RETURN .F.
   end */
RETURN p2


FUNCTION _EVALUA_EXPR(p,par,ITERACION,tBUFFER,FILENAME)
LOCAL res,pila,m,n,o,h,i,j,id:=0,ids:=0,c1,c2,c3,fp,str,nLength,xvar,NUMTOK:=0
LOCAL VARTABLE:=ARRAY(10),JMP:={},LENJMP:=0,vn,vo,SWEDIT:=.F.,num,LENP,pilaif,tmpPos
   pila:={}
   pilaif:={}
   tmpPos:=0   // guarda la ultima posicion de RANGE, para busquedas iterativas, por linea
   afill(VARTABLE,"")
   NUMTOK:=numtoken(par,DEFTOKEN)
   if pcount()==5
    //  tBUFFER:=array(len(BUFFER))
    //  ACOPY(BUFFER,tBUFFER)
      SWEDIT:=.T.
   end
   LENP:=len(p)
   //while !empty(p)
   for i:=1 to LENP
      if inkey()==27
         exit
      end
      //m:=SDC(p)
      m:=p[i]
    //  ? "DATA= ",m
      if valtype(m)=="C"
         if m=="#"
            AADD(pila,par+chr(0))
      //      ? "PARAM: ",par; inkey(0)

         elseif m $ "+*-/^%\"
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA")
               RETURN .F.
            end
            vn:=valtype(n)
            vo:=valtype(o)
            if vn=="C"
               if substr(n,len(n),1)!=chr(0)  //!(chr(0) $ n)
                  c1:=alltrim(n)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     n:=val(c1)
                  else
                     if ISNOTATION(c1)==1
                        n:=e2d(c1)
                     end
                  end
                  end
               end
            end
            vn:=valtype(n)
            
            if vo=="C"
               if substr(o,len(o),1)!=chr(0)  //!(chr(0) $ o)
                  c1:=alltrim(o)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     o:=val(c1)
                  else
                     if ISNOTATION(c1)==1
                        o:=e2d(c1)
                     end
                  end
                  end
               end
            end
            vo:=valtype(o)
            if m=="+"
               if vn=="N"
                  if vo=="N"
                     AADD(pila,o+n)
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila, substr(o,n,len(o))+chr(0))
                  end
               elseif vo=="N"
                  n:=strtran(n,chr(0),"")
                  AADD(pila, substr(n,o,len(n))+chr(0))
               else // sea numeros o strings
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  AADD(pila,(o+n)+chr(0))  // concatena
               end
            elseif m=="-"
               if vn=="N" 
                  if vo=="N"
                     AADD(pila,o-n)
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila, substr(o,1,len(o)-n)+chr(0))
                  end
               else
                  if vo=="N"
                     n:=strtran(n,chr(0),"")
                     AADD(pila, substr(n,1,len(n)-o))
                  else   // elimina TRE con ""
                     n:=strtran(n,chr(0),"")
                     o:=strtran(o,chr(0),"")
                     //?"N=",n," O=",o
                     
                     if len(n)>0 .and. len(o)>0
                     if len(o)>=len(n)
                     id:=numat(n,o)
                     if id>0
                        j:=1
                        while j<=id
                           ids:=atnum(n,o,j)
                           if ids>1
                              c1:=substr(o,ids-1,1)
                           else
                              c1:="."
                           end
                           c2:=substr(o,len(n)+ids,1)
                           if len(c2)==0
                              c2:="."
                           end
                           if !isalpha(c1) .and. !isdigit(c1) .and. !isalpha(c2) .and. !isdigit(c2)
                              c1:=substr(o,1,ids-1)
                              c2:=substr(o,ids+len(n),len(o))
                              o:=c1+c2
                           end
                           ++j
                        end
                     end
                     end
                     end
                  //   ??" O=",o; inkey(0)
                     aadd(pila,o+chr(0))
                  end
               end
            elseif m=="*"
               if vn=="N"
                  if vo=="N"
                     AADD(pila,o*n)
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila, replicate(o,n)+chr(0))
                  end
               else
                  if vo=="N"
                     n:=strtran(n,chr(0),"")
                     AADD(pila, replicate(n,o)+chr(0))
                  else
                     n:=strtran(n,chr(0),"")
                     o:=strtran(o,chr(0),"")
                    /// ? ">>",CHARMIX(n,o) ; inkey(0)
                     AADD(pila, CHARMIX(o,n)+chr(0))
                  end
               end
            elseif m=="/"
               if vn=="N" 
                  if vo=="N"
                     if n!=0
                        AADD(pila,o/n)
                     else
                        AADD(pila,"DIV/0")
                     end
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila,substr(o,n,len(o))+chr(0))
                  end
               else
                  if vo=="C"
                     n:=strtran(n,chr(0),"")
                     o:=strtran(o,chr(0),"")
                     AADD(pila, CHARONLY(n,o)+chr(0)) // solo deja en "n" los caracteres de "o"
                  else
                     n:=strtran(n,chr(0),"")
                     AADD(pila,substr(n,1,o)+chr(0))
                  end
               end
            elseif m=="\"
               if vn=="N" 
                  if vo=="N"
                     if n!=0
                        AADD(pila,int(o/n))
                     else
                        AADD(pila,"DIV/0")
                     end
                  else 
                     o:=strtran(o,chr(0),"")
                     AADD(pila, atadjust(o,par,n,1,," ")+chr(0))
                  end
               else
                  AADD(pila,"TYPE-\-ERROR")
               end
            elseif m=="^"
               if vn=="N"
                  if vo=="N"
                     AADD(pila,o^n)
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila, posins(par,o,n)+chr(0))
                  end
               else
                  if vo=="C"   // AF busca exacta
                     n:=strtran(n,chr(0),"")
                     o:=strtran(o,chr(0),"")
                     id:=numat(n,o)
                     if id>0
                        j:=1
                        while j<=id
                           ids:=atnum(n,o,j)
                           if ids>1
                              c1:=substr(o,ids-1,1)
                           else
                              c1:="."
                           end
                           c2:=substr(o,len(n)+ids,1)
                           if len(c2)==0
                              c2:="."
                           end
                           if !isalpha(c1) .and. !isdigit(c1) .and. !isalpha(c2) .and. !isdigit(c2)
                              AADD(pila, ids )
                              exit
                           end
                           ++j
                        end
                        if j>id
                           aadd(pila,0)
                        end
                     else
                        aadd(pila,0)
                     end
                  else
                     AADD(pila,"TYPE-^-ERROR")
                  end
               end
            elseif m=="%"
               if vn=="N" .and. vo=="N"
                  AADD(pila,o%n)
               elseif vn=="C" .and. vo=="C"
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  AADD(pila, iif(LIKE(n,o),0,1))
               else
                  AADD(pila,"TYPE-%-ERROR")
               end
            end

         elseif m=="FNA"
            m:=p[++i]
            
            if m=="NT"
               AADD(pila,NUMTOK)
            
            elseif m=="VAR"
               o:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if o>=1 .and. o<=10
                     aadd(PILA,VARTABLE[o])
               else
                  _ERROR("EVALUADOR: REGISTRO "+HB_NTOS(o)+" NO EXISTE @(<<1..10>>) L:"+hb_ntos(i) )
                  return .F.
               end
               
            elseif m=="MOV"
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if o>=1 .and. o<=10
                     VARTABLE[o]:=n
               else
                  _ERROR("EVALUADOR: REGISTRO "+HB_NTOS(o)+" NO EXISTE MOV(<<1..10>>,...) L:"+hb_ntos(i) )
                  return .F.
               end

            elseif m==chr(126)  // not
               n:=SDP(pila)
               if n==NIL
                  _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION ~(EXPR) (NOT) ")
                  RETURN .F.
               end
               vn:=valtype(n)
               if vn=="N"
                  if n!=0
                     AADD(pila,0)
                  else
                     AADD(pila,1)
                  end
               else
                  _ERROR("EVALUADOR: TIPO NUMERICO ESPERADO EN ~(EXPR) (NOT) ")
                  RETURN .F.
               end
            elseif m=="I"
               AADD(pila,ITERACION)
            end
            
         elseif m=="FNB"
            m:=p[++i]
            if m=="ELSE"  // JNZ fue verdadero: debe sartar else
               ++i
               while i<=LENP
                  if valtype(p[i])=="C"
                     if p[i]=="ELSE" 
                        if len(pilaif)==0
                            exit
                        end
                     elseif p[i]=="ENDIF"
                        if len(pilaif)>0
                           asize(pilaif,len(pilaif)-1)
                        else
                           exit
                        end
                     elseif p[i]=="JNZ"  // pone en pila
                        aadd(pilaif,1)
                     end
                  end
                  ++i
               end
               if len(pilaif)>0
                  _ERROR("EVALUADOR ':': EXPRESION << EXPR ? >> MAL FORMADA")
                  RETURN .F.
               end
            elseif m=="ENDIF"
               ;
            elseif m=="JNZ"
               n:=SDP(pila)
               if n!=NIL
                  if valtype(n)=="N"
                     n:=alltrim(str(n))
                  end
                  n:=strtran(n,chr(0),"")
                 // ? "JNZ=",n; inkey(0)
                  IF LEN(n)>0 .and. n!="0"  // busco "ELSE"
                     ++i
                     while i<=LENP
                        if valtype(p[i])=="C"
                           if p[i]=="ELSE" 
                              if len(pilaif)==0
                                 exit
                              end
                           elseif p[i]=="ENDIF"
                              if len(pilaif)>0
                                 asize(pilaif,len(pilaif)-1)
                              else
                                 exit
                              end
                           elseif p[i]=="JNZ"  // pone en pila
                              aadd(pilaif,1)
                           end
                        end
                        ++i
                     end
                     if len(pilaif)>0
                        _ERROR("EVALUADOR '?': EXPRESION << EXPR ? >> MAL FORMADA ")
                        RETURN .F.
                     end
                  END
               else
                  _ERROR("EVALUADOR '?': NO EXISTE UNA EXPRESION PARA ? << EXPR ? >>")
                     RETURN .F.
               end
            end
         
         elseif m=="FNC"
            m:=p[++i]
            if m=="ROUND"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,ROUND(n,o))
            
            elseif m=="LOOP"
               if LENJMP>0
                  n:=SDP(pila)
                
                  if valtype(n)!="N"
                     n:=val(n)
                  end
               /// ? "n = ",n ; inkey(0)
                  if n==0
                     --LENJMP
                     ASIZE(JMP,LENJMP)
                  else
                     i:=JMP[LENJMP]
                  end
               else
                  _ERROR("EVALUADOR: LOOP sin POOL") 
                  return .F.
               end
               
            elseif m=="POOL"
               if i<LENP
                  aadd(JMP,i)
                  LENJMP:=len(JMP)
               end
            
            elseif m=="UTF8"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,hb_strtoutf8(n)+chr(0))

            elseif m=="ANSI"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,hb_utf8tostr(n)+chr(0))
            end
         
         elseif m=="FND"
            m:=p[++i]
            
            if m=="MATCH"  // match(#,"hola\;funcion()\;v=a * (b - c)")
               n:=SDP(pila)  // palabras a buscar
               o:=SDP(pila)  // variable: debe ser string
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               xvar:=0
               // busca tokens:
               n:=strtran(n,"\;",chr(1))
               id:=numtoken(n,chr(1))
               j:=1
               while j<=id
                  ids:=token(n,chr(1),j)
                     
                  c3:=atnum(ids,o,1)
                  if c3>0
                     if c3>1
                        c1:=substr(o,c3-1,1)
                     else
                        c1:="."
                     end
                     c2:=substr(o,c3+len(ids),1)
                     if len(c2)==0
                        c2:="."
                     end
                     if !isalpha(c1) .and. !isdigit(c1) .and. !isalpha(c2) .and. !isdigit(c2)
                        ++xvar
                     end
                  end
                  ++j
               end
               aadd(pila,alltrim(str(xvar-id))+chr(0))

            elseif m=="CAT"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               if len(n)==0
                  AADD(pila,o+chr(0))
               elseif len(o)==0
                  AADD(pila,n+chr(0))
               else
                  AADD(pila,(n+o)+chr(0))
               end
            
            elseif m=="SUB"
               m:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
            //   ? "o=",o,"n=",n,"m=",m; inkey(0)
               if valtype(m)!="N" .or. valtype(n)!="N"
                  _ERROR("EVALUADOR: NECESITO INDICES NUMERICOS EN SUB(#, <<M>>, <<N>>)")
                  return .F.
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               o:=strtran(o,chr(0),"")
               if n==0 .or. m==0
                  AADD(pila,""+chr(0))   // opcion: no pone nada.
               else
                  AADD(pila,substr(o,n,m)+chr(0))
               end

            elseif  m=="AT"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               AADD(pila, at(o,n) )
               
            elseif m=="LEN"
               n:=SDP(pila)
               if valtype(n)=="N"
                  AADD(pila,len(alltrim(str((n)))))
               else
                  n:=strtran(n,chr(0),"")
                  AADD(pila,len(n))
               end
            elseif m=="RANGE"
               o:=SDP(pila)
               n:=SDP(pila)
               h:=SDP(pila)
               if valtype(h)=="N"
                  h:=alltrim(str(h))
               end
               h:=strtran(h,chr(0),"")
               if valtype(n)!="N"
                  n:=val(n)
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               tmpPos:=POSRANGE(chr(n),chr(o),h,,tmpPos)
              // ? tmpPos
               AADD(pila,tmpPos)
            end
         
         elseif m=="FNE"
            m:=p[++i]
            
            if  m=="AF"   // busca full
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               id:=numat(o,n)
               if id>0
                  j:=1
                  while j<=id
                     ids:=atnum(o,n,j)
                   //  c1:=substr(n,ids-1,1)
                   //  c2:=substr(n,len(o)+ids,1)
                     if ids>1
                        c1:=substr(n,ids-1,1)
                     else
                        c1:="."
                     end
                     c2:=substr(n,len(o)+ids,1)
                     if len(c2)==0
                        c2:="."
                     end
                     if !isalpha(c1) .and. !isdigit(c1) .and. !isalpha(c2) .and. !isdigit(c2)
                        AADD(pila, ids )
                        exit
                     end
                     ++j
                  end
                  if j>id
                     aadd(pila,0)
                  end
               else
                  aadd(pila,0)
               end
            
            elseif m=="TR"
               m:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(m)=="N"
                  m:=alltrim(str(m))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               m:=strtran(m,chr(0),"")
               o:=strtran(o,chr(0),"")
               AADD(pila,strtran(o,n,m)+chr(0))
            
            elseif m=="CP"
               o:=SDP(pila)
               n:=SDP(pila)
             //  ? "O=",o," N=",n; inkey(0)
               if valtype(o)!="N"
                  _ERROR("EVALUADOR: ESPERO UN NUMERO EN CP(#, <<N>>)")
                  return .F.
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,replicate(n,o)+chr(0))

            elseif  m=="RAT"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")

               AADD(pila, rat(o,n) )

            elseif  m=="PTRP"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               n:=strtran(n,chr(0),"")
               AADD(pila, substr(n,o,len(n))+chr(0))

            elseif  m=="PTRM"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
             //  n:=strtran(n,'"',"")
               n:=strtran(n,chr(0),"")
               AADD(pila, substr(n,1,len(n)-o)+chr(0))  
            end

         elseif m=="FNF"
            m:=p[++i]
            
            if m=="TK"
               m:=SDP(pila)
            //   n:=SDP(pila)
               o:=SDP(pila)
            //   ? "o=",o,"n=",n,"m=",m; inkey(0)
               if valtype(m)!="N"
                  m:=val(m)
               end
              /* if valtype(n)=="N"
                  n:=alltrim(str(n))
               end*/
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               o:=strtran(o,chr(0),"")
              // ? "M=",m; inkey(0)
               if m==0
                  AADD(pila,par+chr(0))
               elseif m<0
                  _ERROR("EVALUADOR: NO ACEPTO UN INDICE DE TOKEN NEGATIVO")
                  return .F.
               else
                  n:=alltrim(token(o,DEFTOKEN,m))
                  if ISTNUMBER(n)==1
                     AADD(pila,val(n))
                  elseif ISNOTATION(n)==1
                     AADD(pila,e2d(n))
                  else
                     AADD(pila,n+chr(0))
                  end
               end               

            elseif m=="LET"
               h:=SDP(pila)  // string.
               o:=SDP(pila)  // linea.debe ser un número
               if valtype(h)=="N"
                  h:=alltrim(str(h))
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               h:=strtran(h,chr(0),"")
               if o>0 .and. o<=len(tBUFFER)
                  tBUFFER[o]:=h
               else
                  _ERROR("EVALUADOR: LINEA REFERENCIADA EN LET NO EXISTE")
                  return .F.
               end

            elseif m=="LETK"
               h:=SDP(pila)  // token 2. puede ser un string.
               n:=SDP(pila)  // token 1. debe ser un numero, indice de token
               o:=SDP(pila)  // linea
               if valtype(n)!="N"
                  n:=val(n)
               end
               o:=strtran(o,chr(0),"")
               if valtype(h)=="N"  // intercambia tokens
                  c1:=alltrim(token(o,DEFTOKEN,n))
                  c2:=alltrim(token(o,DEFTOKEN,h))
                  j:=numtoken(o,DEFTOKEN)
                  str:=""
                  for xvar:=1 to j
                     if xvar==n
                        str+=c2+DEFTOKEN
                     elseif xvar==h
                        str+=c1+DEFTOKEN
                     else
                        str+=alltrim(token(o,DEFTOKEN,xvar))+DEFTOKEN
                     end
                  end
                  AADD(pila,substr(str,1,len(str)-1)+chr(0))
               else    // cambia el token n por el string h
                  j:=numtoken(o,DEFTOKEN)
                  str:=""
                  h:=strtran(h,chr(0),"")
                  //h:=alltrim(h)
                  for xvar:=1 to j
                     if xvar==n
                        str+=h+DEFTOKEN
                     else
                        str+=alltrim(token(o,DEFTOKEN,xvar))+DEFTOKEN
                     end
                  end
                  AADD(pila,substr(str,1,len(str)-1)+chr(0))
               end
               
            elseif m=="COPY"
               if SWEDIT
                  n:=SDP(pila)
                  if valtype(n)=="N"
                     n:=alltrim(str(n))
                  end
                  n:=strtran(n,chr(0),"")
                //  ?"COPY N=",n; inkey(0)
                  if n==NIL
                     _ERROR("EVALUADOR: NO ENCUENTRO UN DATO VALIDO PARA COPIAR EN BUFFER <<COPY(null)>>")
                     RETURN .F.
                  elseif len(n)>0 .and. n!="0"
                     AADD(tBUFFER,alltrim(n))
                     //SW_HAYBUFFER:=.T.
                  end
               else
                  _ERROR("EVALUADOR: COPY SOLO TRABAJA BAJO CTRL-K4")
                  RETURN .F.
               end
            elseif m=="FILE"
               AADD(pila,FILENAME+chr(0))
            end
         
         elseif m=="FNG"
            m:=p[++i]
            
            if m=="TRI"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=str(n)
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,alltrim(n)+chr(0))
            elseif m=="LTRI"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=str(n)
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,ltrim(n)+chr(0))
            elseif m=="RTRI"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=str(n)
               end
               n:=strtran(n,chr(0),"")
               AADD(pila,rtrim(n)+chr(0))

            elseif m=="UP".or. m=="LO"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str((n)))
            //   else
            //      n:=strtran(n,'"',"")
               end
               n:=strtran(n,chr(0),"")
               if m=="UP"
                  AADD(pila,upper(n)+chr(0))
               else
                  AADD(pila,lower(n)+chr(0))
               end
            
            elseif m=="RP"
               o:=SDP(pila)
               n:=SDP(pila)  // debe sacarlo, porque sino, no reemplaza
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
             //  o:=strtran(o,'"',"")
               o:=strtran(o,chr(0),"")
               AADD(pila,o+chr(0))
            end

         elseif m=="FNH"
            m:=p[++i]
            
            if m=="TRE"
               m:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(m)=="N"
                  m:=alltrim(str(m))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               m:=strtran(m,chr(0),"")
               o:=strtran(o,chr(0),"")
               id:=numat(n,o)
               if id>0
                  j:=1
                  while j<=id
                     ids:=atnum(n,o,j)
                    // c1:=substr(o,ids-1,1)
                    // c2:=substr(o,len(n)+ids,1)
                     if ids>1
                        c1:=substr(o,ids-1,1)
                     else
                        c1:="."
                     end
                     c2:=substr(o,len(n)+ids,1)
                     if len(c2)==0
                        c2:="."
                     end
                     if !isalpha(c1) .and. !isdigit(c1) .and. !isalpha(c2) .and. !isdigit(c2)
                        c1:=substr(o,1,ids-1)
                        c2:=substr(o,ids+len(n),len(o))
                        o:=c1+m+c2
                     end
                     ++j
                  end
               end
               aadd(pila,o+chr(0))

            elseif m=="INS"
               m:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(m)!="N"
                  _ERROR("EVALUADOR: NECESITO LA POSICION NUMERICA EN INS(#,M, <<N>>)")
                  return .F.
               end 
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               o:=strtran(o,chr(0),"")
               if m>0
                  xvar:=substr(o,m+1,len(o))
                  n:=strtran(n,chr(0),"")
                  
                  AADD(pila,substr(o,1,m)+n+xvar+chr(0))
               else
                  AADD(pila,o+chr(0))
               end
               
            elseif m=="RPC"
               m:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(m)=="N"
                  m:=alltrim(str(m))
               end 
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               n:=strtran(n,chr(0),"")
               m:=strtran(m,chr(0),"")
               o:=strtran(o,chr(0),"")
               AADD(pila,CHARREPL(n,o,m)+chr(0))
               
            elseif m=="ONE"
               n:=SDP(pila)  // caracter a reducir
               o:=SDP(pila)  // variable: debe ser string
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               AADD(pila,CHARONE(n,o)+chr(0))
               
            elseif m=="DC"
               n:=SDP(pila)  // caracteres a eliminar
               o:=SDP(pila)  // variable: debe ser string
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               AADD(pila,CHARREM(n,o)+chr(0))
            end
         
         elseif m=="FNI"
            m:=p[++i]
            
            if m=="LIN"
               n:=SDP(pila)
               //? "N=",n; inkey(0)
               if valtype(n)!="N"
                  n:=val(n)
               end
               if n>0 .and. n<=LEN(tBUFFER)
                  //AADD(pila,STRING[n]) //strtran(BUFFER[n],chr(127),""))
                  AADD(pila,tBUFFER[n])
               else
                  _ERROR("EVALUADOR: NO EXISTE LA LINEA PEDIDA EN EL BUFFER (LIN)")
                  RETURN .F.
               end

            elseif m=="CH"
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
                 // if n<=0 .or. n>255
                 //    AADD(pila,"null")
                 // else
                 //    AADD(pila,chr(n)+chr(0))
                 // end
               //else
               end
                  AADD(pila,chr(n)+chr(0))
               //end

            elseif m=="VAL"
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=strtran(n,chr(0),"")
                  if ISTNUMBER(n)==1
                     AADD(pila,val(n))
                  elseif ISNOTATION(n)==1
                     AADD(pila,e2d(n))
                  else
                     _ERROR("EVALUADOR: CONVERSION NO VALIDA EN VAL <<VAL( STRING-NO-NUMERIC )>>")
                     RETURN .F.
                  end
               else
                  AADD(pila,n)
               end

            elseif m=="STR"
               n:=SDP(pila)
               if valtype(n)=="N"
                  AADD(pila,alltrim(str(n))+chr(0))
               else
                  n:=strtran(n,chr(0),"")
                  AADD(pila,n+chr(0))
               end
               
            elseif  m=="PC".or.m=="PL".or.m=="PR"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               n:=strtran(n,chr(0),"")
               if m=="PC"
                  AADD(pila, padc(n,o)+chr(0))
               elseif m=="PL"
                  AADD(pila, padl(n,o)+chr(0))
               else
                  AADD(pila, padr(n,o)+chr(0))
               end               

            elseif m=="ASC"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               IF LEN(n)>1
                  n:=substr(n,1,1)
               end
               AADD(pila,asc(n))
            end
               
         elseif m=="FNJ"
            m:=p[++i]
            
            if m=="MSK"
               n:=SDP(pila)  // relleno y mascara
               o:=SDP(pila)  // variable: debe ser numerico
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
             //  o:=strtran(o,'"',"")
               n:=strtran(n,chr(0),"")
               c1:=substr(n,1,1)    // relleno
               c2:=substr(n,2,len(n)) // mascara
               AADD(pila,XFUNMASK(o,c2,c1)+chr(0))
               
            elseif m=="MON"
               h:=SDP(pila)  // decimales
               m:=SDP(pila)  // ancho
               n:=SDP(pila)  // relleno y signo moneda
               o:=SDP(pila)  // variable: debe ser numerico
               if valtype(h)!="N"
                  m:=val(m)
               end
               if valtype(m)!="N"
                  m:=val(m)
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               //n:=strtran(n,'"',"")
               c1:=substr(n,1,1)    // relleno
               c2:=substr(n,2,len(n)) // tipo moneda
               if valtype(o)!="N"
                  o:=val(o)
               end
               AADD(pila,XFUNMONEY(o,c2,c1,h,m)+chr(0))
               
            elseif m=="SAT"
               o:=SDP(pila)
               n:=SDP(pila) 
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               o:=strtran(o,chr(0),"")
               o:=strtran(o,"\n",HB_OSNEWLINE())
               n:=strtran(n,chr(0),"")
             //  n:=strtran(n,'"',"")
               AADD(pila, XFUNCCCSATURA(n, DEFTOKEN, o)+chr(0))

            elseif m=="IF" .or. m=="IFLE" .or. m=="IFGE"
               h:=SDP(pila)
               n:=SDP(pila)
               o:=SDP(pila)
               if valtype(h)=="N"
                  h:=alltrim(str(h))
               end
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               if valtype(o)=="N"
                  o:=alltrim(str(o))
               end
               h:=strtran(h,chr(0),"")
               n:=strtran(n,chr(0),"")
               o:=strtran(o,chr(0),"")
               if m=="IF"
                  if len(alltrim(o))==0 .or. o=="0"
                     AADD(pila,n)
                  else
                     AADD(pila,h)
                  end
               elseif m=="IFLE"
                  if val(o)<=0 .and. ISTNUMBER(o)==1
                     AADD(pila,n)
                  else
                     AADD(pila,h)
                  end
               else
                  if val(o)>=0 .and. ISTNUMBER(o)==1
                     AADD(pila,n)
                  else
                     AADD(pila,h)
                  end
               end

            elseif m=="DEFT"
               h:=SDP(pila)  // string.
               if valtype(h)=="N"
                  h:=alltrim(str(h))
               end
               h:=strtran(h,chr(0),"")
               DEFTOKEN:=h
               NUMTOK:=numtoken(par,DEFTOKEN) // defino variable global
            
            elseif m=="CLEAR"
               asize(tBUFFER,0)
               exit
            end
                
         elseif m=="FNK"
            m:=p[++i]
            
            if m=="NOP"
               AADD(pila,"")
            elseif m=="AND"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,iif(o==0 .and. n==0,0,1))
            elseif m=="OR"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,iif(o==0 .or. n==0,0,1))
            elseif m=="XOR"
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(o)!="N"
                  o:=val(o)
               end
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,iif((o==0.and.n!=0).or.(o!=0.and.n==0),0,1))
            end
         
         elseif m=="FNL"
            m:=p[++i]
            
            if m=="BIT"  // ontiene un bit n
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               AADD(pila,XGETBIT(n,o,1))

            elseif m=="ON"   // enciende un bit n
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               AADD(pila,XSETBIT(n,o+1))
            elseif m=="OFF"   // apaga un bit n
               o:=SDP(pila)
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               if valtype(o)!="N"
                  o:=val(o)
               end
               AADD(pila,XCLEARBIT(n,o+1))
               
            elseif m=="NOT"   // negacion binaria
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,XNUMNOT(n))
            
            elseif m=="BIN"   // convierte a binario
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,DECTOBIN(n)+chr(0))
            elseif m=="HEX"   // convierte a hexadecimal
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,DECTOHEXA(n)+chr(0))
            elseif m=="OCT"   // convierte a OCTAL
               n:=SDP(pila)
               if valtype(n)!="N"
                  n:=val(n)
               end
               AADD(pila,DECTOOCTAL(n)+chr(0))

            elseif m=="DEC"
               n:=SDP(pila)
               if valtype(n)=="N"
                  n:=alltrim(str(n))
               end
               n:=strtran(n,chr(0),"")
               num:=""
               c1:=substr(n,1,2)
               c2:=substr(n,len(n),1)
              // ?"C1=",c1," C2=",c2; inkey(0)
               if c1!="0x" .or. !(c2 $ "bho")
                  _ERROR("EVALUADOR: BASE NUMERICA NO RECONOCIDA: "+n)
                    RETURN .F.
               end
               n:=substr(n,3,len(n))
               IF LEN(n)>1
                  num:=""
                  j:=1
                  while j<=LEN(n)
                    c:=substr(n,j,1)
                    if isdigit(c) .or. c=="A".or.c=="B".or.c=="C".or.c=="D".or.c=="E".or.c=="F"
                       num+=c
                    else
                       exit
                    end
                    ++j
                  end
                 // ? "NUM=",num; inkey(0)
                  if c=="b"     // es binairo
                    for j:=1 to len(num)
                      xt:=substr(num,j,1)
                      if xt!="0" .and. xt!="1"
                        _ERROR("EVALUADOR: NUMERO BINARIO MAL FORMADO: "+num)
                        RETURN .F.
                      end
                    end
                    num:=BINTODEC(num)
                  elseif c=="o"   // es octal
                    for j:=1 to len(num)
                      xt:=substr(num,j,1)
                      if !(xt $ "01234567")
                        _ERROR("EVALUADOR: NUMERO OCTAL MAL FORMADO: "+num)
                        RETURN .F.
                      end
                    end
                    num:=OCTALTODEC(num)
                  elseif c=="h"    // es hexadecimal
                    
                    for j:=1 to len(num)
                      xt:=substr(num,j,1)
                      if !(xt $ "0123456789ABCDEF")
                         _ERROR("EVALUADOR: NUMERO HEXADECIMAL MAL FORMADO: "+num)
                         RETURN .F.
                      end
                    end
                    num:=HEXATODEC(num)
                  else   // no es ninguna hueá: error!
                    _ERROR("EVALUADOR: BASE NUMERICA NO RECONOCIDA: "+num)
                    RETURN .F.
                  end
               else
                  _ERROR("EVALUADOR: NO HAY NUMERO A CONVERTIR: "+num)
                    RETURN .F.
               end
               AADD(pila,num)

            end

         elseif m=="FNM"
            m:=p[++i]
            n:=SDP(pila)
            if valtype(n)!="N"
               n:=alltrim(n)
               n:=strtran(n,chr(0),"")
               if ISTNUMBER(n)==1
                  n:=val(n)
               elseif ISNOTATION(n)==1
                  n:=e2d(n)
               else
                  _ERROR("EVALUADOR: OPERANDO NO ES UN NUMERO "+n)
                  RETURN .F.
               end
            end
            if m=="INT"
               AADD(pila,int(n))
            elseif m=="CEIL"
               AADD(pila,ceiling(n))
            elseif m=="SQRT"
               AADD(pila,sqrt(n))
            elseif m=="ABS"
               AADD(pila,abs(n))
            elseif m=="LN"
               AADD(pila,log(n))
            elseif m=="LOG"
               AADD(pila,log10(n))
            elseif m=="EXP"
               AADD(pila,exp(n))
            end

         elseif m=="FNN"
            m:=p[++i]
            n:=SDP(pila)
            if valtype(n)!="N"
               n:=alltrim(n)
               n:=strtran(n,chr(0),"")
               if ISTNUMBER(n)==1
                  n:=val(n)
               elseif ISNOTATION(n)==1
                  n:=e2d(n)
               else
                  _ERROR("EVALUADOR: OPERANDO NO ES UN NUMERO "+n)
                  RETURN .F.
               end
            end
            if m=="FLOOR"
               AADD(pila,floor(n))
            elseif m=="SGN"
               AADD(pila,sign(n))
            elseif m=="INV"
               AADD(pila,1/n)
            elseif m=="SIN"
               AADD(pila,sin(n))
            elseif m=="COS"
               AADD(pila,cos(n))
            elseif m=="TAN"
               AADD(pila,tan(n))
            end

         elseif m==">>"   // desplazamiento según si es numero o caracter
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA >> ")
               RETURN .F.
            end
            vn:=valtype(o)+valtype(n)
            if vn=="NN"
               AADD(pila,HB_BITSHIFT(o,n*(-1)))
            elseif vn=="CN"
               AADD(pila,CHARSHR(o,n)+chr(0))
            else
               _ERROR("EVALUADOR: TIPOS DISTINTOS EN OPERACION BINARIA >> ")
               RETURN .F.
            end

         elseif m=="<<"   // desplazamiento según si es numero o caracter
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA << ")
               RETURN .F.
            end
            vn:=valtype(o)+valtype(n)
            if vn=="NN"
               AADD(pila,HB_BITSHIFT(o,n))
            elseif vn=="CN"
               AADD(pila,CHARSHL(o,n)+chr(0))
            else
               _ERROR("EVALUADOR: TIPOS DISTINTOS EN OPERACION BINARIA << ")
               RETURN .F.
            end

         elseif m=="&"  // and
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA & (AND) ")
               RETURN .F.
            end
            vn:=valtype(n)+valtype(o)
            if vn=="NN"
               AADD(pila,XNUMAND(o,n))
            elseif vn=="CC"
               AADD(pila,CHARAND(o,n)+chr(0))
            else
               _ERROR("EVALUADOR: TIPOS DISTINTOS EN OPERACION BINARIA & (AND) ")
               RETURN .F.
            end

         elseif m=="|"  // or
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA | (OR) ")
               RETURN .F.
            end
            vn:=valtype(n)+valtype(o)
            if vn=="NN"
               AADD(pila,XNUMOR(o,n))
            elseif vn=="CC"
               AADD(pila,CHAROR(o,n)+chr(0))
            else
               _ERROR("EVALUADOR: TIPOS DISTINTOS EN OPERACION BINARIA | (OR) ")
               RETURN .F.
            end

         elseif m=="!"  // xor
            n:=SDP(pila)
            o:=SDP(pila)
            if n==NIL .or. o==NIL
               _ERROR("EVALUADOR: EXPRESION MAL FORMADA EN OPERACION BINARIA ! (XOR) ")
               RETURN .F.
            end
            vn:=valtype(n)+valtype(o)
            if vn=="NN"
               AADD(pila,XNUMXOR(o,n))
            elseif vn=="CC"
               AADD(pila,CHARXOR(o,n)+chr(0))
            else
               _ERROR("EVALUADOR: TIPOS DISTINTOS EN OPERACION BINARIA ! (XOR) ")
               RETURN .F.
            end

         else
            aadd(pila,m)
         end
      elseif valtype(m)=="N"
         aadd(pila,m)
      end
  //    ? "PILA=",len(pila)
   end
 //  ? "PILA FINAL=",len(pila)
/*   if SWEDIT      
      ASIZE(@BUFFER,len(tBUFFER))
      ACOPY(tBUFFER,@BUFFER)
      SWEDIT:=.F.
   end */
   
   if len(pila)>1 //.or. len(pila)==0
    /*  ? "PILA TIENE PROBLEMAS"
      for i:=1 to len(pila)
         ? ">>>>",pila[i]
      end 
 */
      _ERROR("EVALUADOR: EXPRESION MAL FORMADA (QUEDAN "+hb_ntos(len(pila))+" RESULTADOS EN PILA).")
      RETURN .F.
   end
//RETURN iif(len(pila)==1,pila[1],"")
RETURN iif(len(pila)>=1,pila[len(pila)],"")


PROCEDURE _ERROR(msg)
   outstd(_CR+msg+_CR+_CR)
RETURN

/*
 * Conversion Funtions
 *
 * Copyright 1999 Luiz Rafael Culik <Culik@sl.conex.net>
 */

FUNCTION DecToBin( nNumber )

   LOCAL cNewString := ""
   LOCAL nTemp

   DO WHILE nNumber > 0
      nTemp := nNumber % 2
      cNewString := SubStr( "01", nTemp + 1, 1 ) + cNewString
      nNumber := Int( ( nNumber - nTemp ) / 2 )
   ENDDO

   RETURN cNewString

FUNCTION DecToOctal( nNumber )

   LOCAL cNewString := ""
   LOCAL nTemp

   DO WHILE nNumber > 0
      nTemp := nNumber % 8
      cNewString := SubStr( "01234567", nTemp + 1, 1 ) + cNewString
      nNumber := Int( ( nNumber - nTemp ) / 8 )
   ENDDO
   if len(cNewString)==0
      cNewString:="0"
   end
   RETURN cNewString

FUNCTION DecToHexa( nNumber )

   LOCAL cNewString := ""
   LOCAL nTemp

   DO WHILE nNumber > 0
      nTemp := nNumber % 16
      cNewString := SubStr( "0123456789ABCDEF", nTemp + 1, 1 ) + cNewString
      nNumber := Int( ( nNumber - nTemp ) / 16 )
   ENDDO
   if len(cNewString)==0
      cNewString:="0"
   end
   RETURN cNewString

FUNCTION BinToDec( cString )

   LOCAL nNumber := 0, nX
   LOCAL cNewString := AllTrim( cString )
   LOCAL nLen := Len( cNewString )

   FOR nX := 1 TO nLen
      nNumber += ( At( SubStr( cNewString, nX, 1 ), "01" ) - 1 ) * ( 2 ^ ( nLen - nX ) )
   NEXT

   RETURN nNumber

FUNCTION OctalToDec( cString )

   LOCAL nNumber := 0, nX
   LOCAL cNewString := AllTrim( cString )
   LOCAL nLen := Len( cNewString )

   FOR nX := 1 TO nLen
      nNumber += ( At( SubStr( cNewString, nX, 1 ), "01234567" ) - 1 ) * ( 8 ^ ( nLen - nX ) )
   NEXT

   RETURN nNumber

FUNCTION HexaToDec( cString )

   LOCAL nNumber := 0, nX
   LOCAL cNewString := AllTrim( cString )
   LOCAL nLen := Len( cNewString )

   FOR nX := 1 TO nLen
      nNumber += ( At( SubStr( cNewString, nX, 1 ), "0123456789ABCDEF" ) - 1 ) * ( 16 ^ ( nLen - nX ) )
   NEXT

   RETURN nNumber

function es_funcion(arg)
//local _pos:=0,_ret:=.F.,DICC,i,long
local DICC
DICC:={"LN","LOG","SQRT","ABS","INT","CEIL","FLOOR","SGN","ROUND","SIN","COS","TAN","UP","LO","MSK","MON","SAT",;
       "EXP","INV","RP","CAT","LEN","SUB","AT","AF","RAT","PTRP","PTRM","CP","TR","TK","VAL","CH","LIN","PC","PL","PR","IF",;
       "TRE","INS","DC","RPC","ONE","ASC","TRI","LTRI","RTRI","I","INC","DEC","IFLE","IFGE","LETK","MATCH","LET","DEFT",;
       "NT","POOL","LOOP","MOV","VAR","NOP","COPY","AND","OR","XOR","NOT","BIT","ON","OFF","BIN","HEX","OCT","~",;
       "JNZ","ELSE","ENDIF","CLEAR","RANGE","FILE","STR","UTF8","ANSI",;
       "FNA","FNB","FNC","FND","FNE","FNF",;
       "FNH","FNI","FNJ","FNK","FNL","FNM","FNN"}

/*cFUN:={"FNA","FNA","FNA","FNA","FNA",;
       "FNB","FNB","FNB",;
       "FNC","FNC","FNC",;
       "FND","FND","FND","FND","FND",;
       "FNE","FNE","FNE","FNE","FNE","FNE",;
       "FNF","FNF","FNF","FNF",;
       "FNG","FNG","FNG","FNG","FNG","FNG",;
       "FNH","FNH","FNH","FNH","FNH",;
       "FNI","FNI","FNI","FNI","FNI","FNI","FNI";
       "FNJ","FNJ","FNJ","FNJ","FNJ","FNJ","FNJ";
       "FNK","FNK","FNK","FNK",;
       "FNL","FNL","FNL","FNL","FNL","FNL","FNL","FNL",;
       "FNM","FNM","FNM","FNM","FNM","FNM","FNM",;
       "FNN","FNN","FNN","FNN","FNN","FNN"}

DICC:={"NT","I","VAR","MOV","~",;   // A
       "JNZ","ELSE","ENDIF",;   // B
       "POOL","LOOP","ROUND";           // C
       "CAT","MATCH","LEN","SUB","AT",;  // D
       "AF","RAT","PTRP","PTRM","CP","TR",;  // E
       "TK","LETK","LET","COPY",;    // F     
       "RP","TRI","LTRI","RTRI","UP","LO",;    // G
       "TRE","INS","DC","RPC","ONE",;       // H
       "VAL","CH","ASC","LIN","PC","PL","PR",;    // I
       "MSK","MON","SAT","DEFT","IF","IFLE","IFGE",; // J
       "NOP","AND","OR","XOR",;    // K
       "NOT","BIT","ON","OFF","BIN","HEX","DEC","OCT",; // L
       "LN","LOG","SQRT","ABS","INT","CEIL","EXP",;  // M
       "FLOOR","SGN","SIN","COS","TAN","INV",;       // N
       */
                             
//long:=len(DICC)
//_pos:=Ascan(DICC, arg)
//for i:=1 to long
//   if DICC[i]==arg
//       //_pos:=Ascan(DICC, arg)
//      _ret:=.T.
//      exit
//   end
//end
return iif(Ascan(DICC, arg)>0,.T.,.F.)  //_ret

function es_simbolo(c)
local _ret:=.F.

   if c=="+" .or. c=="-" .or. c=="*" .or. c=="/" .or.c=="%".or.;
      c==")" .or. c=="(" .or. c=="^" .or. c=="\" ;
      .or. c==">>" .or.c=="<<".or.c=="&".or.c=="|".or.c=="!"
      _ret:=.T.
   end

return _ret

function SDP( _lista )
Local _last_valor,_nLongi

_Last_valor:=0
_nLongi := len( _lista )

   // Chequea si existen elementos
   if _nLongi == 0
      return ( nil )
   end

   // obtiene el ultimo valor
   _Last_valor := _lista[ _nLongi ]

   // Remueve el ultimo elemento del stack
   Asize( _lista, _nLongi - 1 )

   // Retorna el elemento extraido
return  _Last_valor 

function SDC( _lista )
local _last_valor,_nLongi
   _Last_valor:=0
   _nLongi := len( _lista )

   // Chequea si existen elementos
   if _nLongi == 0
      return ( nil )
   end

   // obtiene el ultimo valor
   _Last_valor := _lista[ 1 ]

   // Remueve el ultimo elemento del stack
   Adel ( _lista, 1 )
   Asize( _lista, _nLongi - 1 )

   // Retorna el elemento extraido
return  _Last_valor 

FUNCTION FUNFSHELL(AX,TIPO)
LOCAL EAX,BX,DX,EX,RX,CX
 
    EX:=hb_ntos(int(hb_random(1000000000)))
    // prepara respuesta
    BX:="./XU_"+EX 
    // amra el .BAT
    
    AX:=AX+" > "+BX+".tmp"
    DX:=FCREATE (BX+".sh")
     FWRITE (DX,"#!/bin/bash"+_CR)
     FWRITE (DX,AX+_CR)

 //    FWRITE (DX,"echo $? > "+"XUANS_"+EX+".log"+_CR)
    FCLOSE (DX)
    RX:=CMDSYSTEM("chmod 755 "+BX+".sh",0)
//
    // Ejecuta el Batch
    RX:=CMDSYSTEM(BX+".sh",0) // </dev/null >/dev/null 2>&1 &")
  
    
//    while !file(BX+".tmp")
//       ;//? "Aun no existe..."
//    end
    CX:=hb_utf8tostr(MEMOREAD(BX+".tmp"))
//    if TIPO==2
//       CX:=MEMOREAD("XUANS_"+EX+".log")
//       RX:=iif(CX!="0",.F.,.T.)
//    elseif TIPO==3 .or. TIPO==4
       RX:=CX   // guardo salida
//    end
    BX:=strtran(BX,"./","")
    FERASE (BX+".sh")
    FERASE (BX+".tmp")
    FERASE ("XUANS_"+EX+".log")
    
    RELEASE EAX,BX,DX,EX,CX
RETURN RX




/** codigo C **/
#pragma BEGINDUMP
#include "hbapi.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbset.h"
#include "hbdate.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <math.h>
#include <inttypes.h>

void do_fun_xgetbit(){
   unsigned x = hb_parni(1);
   int p = hb_parni(2);
   int n = hb_parni(3);
   hb_retni( (x>> (p+1-n)) & ~(~0 << n) );
}
HB_FUNC ( XGETBIT )
{
   do_fun_xgetbit();
}


/**************************************************************************************/ 
/*
 * CT3 Number and bit manipulation functions:
 *       NumAnd(), NumOr(), NumXor(), NUMNOT()
 *       ClearBit(), SetBit()
 *
 * Copyright 2007 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
 */

HB_BOOL ct_numParam( int iParam, HB_MAXINT * plNum )
{
   const char * szHex = hb_parc( iParam );

   if( szHex )
   {
      *plNum = 0;
      while( *szHex == ' ' )
         szHex++;
      while( *szHex )
      {
         char c = *szHex++;

         if( c >= '0' && c <= '9' )
            c -= '0';
         else if( c >= 'A' && c <= 'F' )
            c -= 'A' - 10;
         else if( c >= 'a' && c <= 'f' )
            c -= 'a' - 10;
         else
            break;
         *plNum = ( *plNum << 4 ) | c;
         iParam = 0;
      }
      if( ! iParam )
         return HB_TRUE;
   }
   else if( HB_ISNUM( iParam ) )
   {
      *plNum = hb_parnint( iParam );
      return HB_TRUE;
   }

   *plNum = -1;
   return HB_FALSE;
}

HB_FUNC( XNUMAND )
{
   int iPCount = hb_pcount(), i = 1;
   HB_MAXINT lValue = -1, lNext = 0;

   if( iPCount && ct_numParam( 1, &lValue ) )
   {
      while( --iPCount && ct_numParam( ++i, &lNext ) )
         lValue &= lNext;

      if( iPCount )
         lValue = -1;
   }
   hb_retnint( lValue );
}

HB_FUNC( XNUMOR )
{
   int iPCount = hb_pcount(), i = 1;
   HB_MAXINT lValue = -1, lNext = 0;

   if( iPCount && ct_numParam( 1, &lValue ) )
   {
      while( --iPCount && ct_numParam( ++i, &lNext ) )
         lValue |= lNext;

      if( iPCount )
         lValue = -1;
   }
   hb_retnint( lValue );
}

HB_FUNC( XNUMXOR )
{
   int iPCount = hb_pcount(), i = 1;
   HB_MAXINT lValue = -1, lNext = 0;

   if( iPCount && ct_numParam( 1, &lValue ) )
   {
      while( --iPCount && ct_numParam( ++i, &lNext ) )
         lValue ^= lNext;

      if( iPCount )
         lValue = -1;
   }
   hb_retnint( lValue );
}

HB_FUNC( XNUMNOT )
{
   HB_MAXINT lValue;

   if( ct_numParam( 1, &lValue ) )
      lValue = ( ~lValue ) & 0xffffffff;
      //lValue = ( ~lValue ) & 0xffffffff;

   hb_retnint( lValue );
}

HB_FUNC( XCLEARBIT )
{
   int iPCount = hb_pcount(), iBit, i = 1;
   HB_MAXINT lValue;

   if( ct_numParam( 1, &lValue ) )
   {
      while( --iPCount )
      {
         iBit = hb_parni( ++i );
         if( iBit < 1 || iBit > 64 )
            break;
         lValue &= ~( ( ( HB_MAXINT ) 1 ) << ( iBit - 1 ) );
      }

      if( iPCount )
         lValue = -1;
   }

   hb_retnint( lValue );
}
HB_FUNC( XSETBIT )
{
   int iPCount = hb_pcount(), iBit, i = 1;
   HB_MAXINT lValue;

   if( ct_numParam( 1, &lValue ) )
   {
      while( --iPCount )
      {
         iBit = hb_parni( ++i );
         if( iBit < 1 || iBit > 64 )
            break;
         lValue |= ( ( HB_MAXINT ) 1 ) << ( iBit - 1 );
      }

      if( iPCount )
         lValue = -1;
   }

   hb_retnint( lValue );
}


uint16_t ftokens(const char *linea, const char *buscar, uint16_t lb) {
   const char *t,*r; // son solo punteros apuntando a la cadena s.

   uint16_t n=0;

   r = linea;  // rescato primera posición
   t = strstr(r,buscar);
   while (t!=NULL) {
      r = t + lb;
      ++n;
      t = strstr(r,buscar);
   }

   return n;
}

char * fun_alltrim( const char *linea, HB_SIZE sizel) {
   const char *r,*s;
   char *t,*buffer;
   HB_SIZE tsize;

   r = linea;
   if ( *r=='\t' || *r=='\r' || *r=='\n' || *r==' ' ){
      while (( *r=='\t' || *r=='\r' || *r=='\n' || *r==' ') && *r) r++; 
      if (!*r) return NULL;  // no hay texto, solo puras weás! 
   }
   s = linea + (sizel-1);
   if (*s=='\t' || *s=='\r' || *s=='\n' || *s==' ') {
      while (( *s=='\t' || *s=='\r' || *s=='\n' || *s==' ') && s!=linea) s--;     
      if (s==linea) return NULL;  // no hay texto, sólo puras weás!
   }
   tsize = s - r + 1;  // longitud del texto.

   buffer = (char *) calloc((tsize+1),1);//sizeof(char *));
   if (buffer==NULL) return NULL;
   t = buffer;
   strncpy (t,r,tsize);
   t[tsize]='\0';

   return buffer;
}
char *strpad (const char *linea, uint16_t size, uint16_t sizel, uint16_t codeFun){
   char *t,*buffer;
   const char *s, *r;
   uint16_t tsize,l1,l2,ts, lsizel;
   int i,p,q;
   
  // acoto el string a padear, por ambos lados (evito llamar a TRIM).
 // printf("\nLinea  %s\n",linea);

 //   printf("ENTRA AQUI\n");
   r = linea;
   if (*r=='\t' || *r=='\r' || *r=='\n' || *r==' '){
      while ((*r=='\t' || *r=='\r' || *r=='\n' || *r==' ') && *r) r++; 
      if (!*r) return NULL;  // no hay texto, sólo puras weás! 
   }
   s = linea + (sizel-1);
   if (*s=='\t' || *s=='\r' || *s=='\n' || *s==' '){
      while ((*s=='\t' || *s=='\r' || *s=='\n' || *s==' ') && s!=linea) s--;     
      if (s==linea) return NULL;  // no hay texto, sólo puras weás!
   }
   tsize = s - r + 1;  // longitud del texto.
 //  printf("\nS= %s, R=%s, TSIZE=%d CPAD=%d SIZECAMPO=%d\n",s,r,tsize,size,sizel);
   if (tsize>sizel) return NULL;
 //  printf("\nPASO... con %s\n",linea);
   lsizel = sizel - strlen(linea);


   l1 = ( (size - tsize) + lsizel ) / 2;
   l2 = l1;

   if (l1+l2+tsize < size+lsizel) l2++;   // por si el pad es impar
   ts = l1+l2+tsize;
// asigno espacio (size) para nueva cadena:
   buffer = (char *) calloc(ts+1,1); //sizeof(char));
   t = buffer;
   if (t==NULL) return NULL;    // todo termina si no hay memoria.
   
   switch( codeFun ){
      case 0: { // centrado
      	p=0;
        while (l1--){
      	  //strcat(t," ");
      	  t[p++] = ' ';
        }
        //strncat(t,r,tsize);
        q=0;
        while (tsize--){
        	 t[p++] = r[q++];
        } 
        while (l2--){
      	 // strcat(t," ");
      	   t[p++] = ' ';
        }
        t[p] = '\0';
        break;
      }
      case 1: {  // Left
      	p=0;
        //strncat(t,r,tsize);
        q=0;
        while (tsize--){
        	 t[p++] = r[q++];
        }
        i = l1 + l2;
        while (i--){
      	  //strcat(t," ");
      	  t[p++] = ' ';
        }
        t[p] = '\0';
        break;
      }
      case 2: {    // Right
        i = l1 + l2;
        p = 0;
        while (i--){
      	  //strcat(t," ");
      	  t[p++] = ' ';
        }
        //strncat(t,r,tsize);
        q=0;
        while (tsize--){
        	 t[p++] = r[q++];
        }
        t[p] = '\0';
        break;
      }
   }
   char * Retorno = (char *)calloc(p+1,1);
   char * Ret = Retorno;
   strcpy(Ret,t);
   free(buffer);
   return Retorno;   
}

#define MAXBUFFER 4096

char *fsaturate( const char *tokens, const char *tok, const char *linea){
   char *buffer;
   const char *t, *s;
   char **ltoken;     // lista de tokens
   uint16_t lentok = strlen(tok);
   uint16_t i=0,l, sizei;

   if (lentok==0) return NULL;

   // cuántos tokens tengo?
   uint16_t ntok = ftokens(tokens,tok,lentok);
   if (ntok==0) return NULL;   // no hay tokens
   //ltoken = (char**)malloc( sizeof(char *)*(ntok+2) );
   ltoken = (char**)calloc( ntok+1, sizeof(char *) );
   // a ntok se suma 1, pues acá necesito los tokens, no los separadores, como en strtran. 

   if (ltoken==NULL) return NULL;   // no hay memoria

   // obtengo tokens y los guardo en un arreglo para reemplazar después.
   t = tokens;
   char *temp;
   while ((s = strstr(t,tok))!=NULL) {
       l = s - t;
       
       ltoken[i] = (char*)calloc( (l+1), 1);//sizeof(char *) );
       temp = ltoken[i];
       if (temp==NULL) {     // limpiar la memoria que ya fue asignada
           //free(ltoken);
           for (l=0;l<=i;++l) free(ltoken[l]);
           free(ltoken);
           return NULL;     // no hay memoria para el arreglo
       }
       //strncpy(ltoken[i], t, l);
       strncpy(temp, t, l);
       t = ++s;
    //   printf("\nTOken... %s\n",ltoken[i]);
       ++i;
   }

   if (t!=NULL) {           // queda un token más: lo capturo.
       ltoken[i] = (char*)calloc( (strlen(t)+1), 1);// sizeof(char *) );
       temp = ltoken[i];
       if (temp==NULL) {     // limpiar la memoria que ya fue asignada
           ///free(ltoken);
           for (l=0;l<=i;++l) free(ltoken[l]);
           free(ltoken);
           return NULL;     // no hay memoria para el arreglo
       }
       
       //strcpy(ltoken[i], t);
       strcpy(temp, t);
       sizei = i;
   } else sizei = i-1;

   // asigno espacio a la línea objetiva
   ///buf = (char *) malloc (sizeof(char *)*MAXBUFFER); // MAXBUFFER lo asgno por flag "512"
   buffer = (char *) calloc (MAXBUFFER,1);//sizeof(char *));
   char *buf = buffer;
   if (buf==NULL) {         // limpiar la memoria que ya fue asignada
       //free(ltoken);
       for (l=0;l<=i;++l) free(ltoken[l]);
       free(ltoken);
       free(buffer);
       return NULL;         // no hay memoria para el arreglo
   }
   // Reemplazo los tokens en la línea objetiva
   uint16_t ncampo=0;
   uint16_t lc=0;
   const char *c, *cc;

  // strcpy(buf,"");
   t = linea;
   while ((s = strstr(t,"$"))!=NULL) {
       l = s - t;
       strncat(buf,t,l);         // rescato porción de linea sin tocar, antes del token
       c = s+1;                  // desde el supuesto dígito en adelante
       while (isdigit(*c)) c++;  // obtengo el número del campo
       lc = c - s;               // longitud del número
       if (lc>1) {               // es un campo. 1= no es un campo
          char *cindice,*cind;        // para guardar los índices
          cindice = (char *) malloc (1*(lc+1));
          cind = cindice;
          if (cind==NULL) {     // limpiar la memoria que ya fue asignada
              ///free(ltoken);
              for (l=0;l<=i;++l) free(ltoken[l]);
              free(ltoken);
              free(buffer);
              return NULL;         // no hay memoria para el arreglo
          }
          
          strncpy(cind,s+1,lc);   // preparo el indice del arreglo para obtener token
          ncampo = atoi(cind);
          if (ncampo<=sizei) {     // es un campo válido??
             // aniadir aqui el pad, si lo hay
             const char * campo = ltoken[ncampo];
             if(*c==':'){  // aqui hay un pad
                cc = c;
                c++;  // me lo salto
                
                char *cPadding;
                char *cPadToken;        // para guardar los índices
                int w=0;
                
                while(isdigit(*c)) {c++;++w;}
                lc = c - ( cc+w);
                cPadding = (char *) calloc (lc+1,1);//sizeof(char *));
                cPadToken = (char * ) calloc (128,1);
                char * cPad = cPadding;
          	strncpy(cPad,(cc+w),lc);
          	
                int nPad = atoi(cPad);
                int sizeCampo = strlen(campo);
          	//printf("\nCIND=%d CPAD = %d sizeCampo=%d Campo=%s",ncampo,nPad,sizeCampo,campo);
                if(toupper(*c) == 'C'){  //0
                   cPadToken=strpad(campo,nPad,sizeCampo,0);
                }else if(toupper(*c) == 'L'){  //1
                   cPadToken=strpad(campo,nPad,sizeCampo,1);
                }else if(toupper(*c) == 'R'){  //2
                   cPadToken=strpad(campo,nPad,sizeCampo,2);
                }else{   // error
                   return NULL;
                }
               // printf("\nENTRA AQUI con %s\n",cPadToken);
                if (cPadToken!=NULL) 
                   strcat(buf,cPadToken);
                else
                   strcat(buf,"");

                // printf("\nESTA OK\n");
                c++;
                free(cPadding);
                free(cPadToken);
             }else{
                //strcat(buf,campo);
                char * cCampo = fun_alltrim( (const char*)campo, (HB_SIZE)strlen(campo));
                if (cCampo == NULL){
                   char * cCampo = (char * )calloc(1,1);
                   cCampo[0]='\0';
                }
                const char * pCampo = cCampo;
              //  printf("\nENTRA AQUI con %s\n",cCampo);
                strcat(buf, pCampo);
              //  printf("\nESTA OK\n");
                free(cCampo);
             }
          }
          t = c;              // siempre: por si o por no, el campo será eliminado igual
          free(cindice);
       } else {
          strncat(buf,s,1);   // rescato "$" que no es un campo
          t = ++s;            // avanzo un espacio y continúo el proceso
       }
   }
   // rescato lo último que no ha sido rescatado
   strcat (buf,t);
   int nLen = strlen(buf);
//   buf[nLen+1]='\0';

   // libero memoria
   
   for (l=0;l<=i;++l) free(ltoken[l]);
   free(ltoken);
   
   char * Retorno = (char *) calloc (nLen+1,1);//sizeof(char));
   char * Ret = Retorno;
   strcpy(Ret,buf);
   
   // deguerbo resultado
   free(buffer);
   return Retorno;
/*
//   buf[strlen(buf)+1]='\0';

   // libero memoria
   
   for (l=0;l<=i;++l) free(ltoken[l]);
   free(ltoken);
   
   // deguerbo resultado
   return buffer; */
}

HB_FUNC( XFUNCCCSATURA )
{
    PHB_ITEM pA = hb_param( 1, HB_IT_STRING ); // tokens
    PHB_ITEM pB = hb_param( 2, HB_IT_STRING ); // B = separador
    PHB_ITEM pD = hb_param( 3, HB_IT_STRING ); // D = linea a rellenar
    
    char * pBuffer;
    pBuffer = (char *)fsaturate( hb_itemGetCPtr( pA ), hb_itemGetCPtr( pB ), 
                                 hb_itemGetCPtr( pD ));
    const char * Ret = pBuffer;
    hb_retc( Ret );
    free(pBuffer);
}

char * fun_xmask(const char *formato, const char *car, const char *numero) {
   char *buffer, *pBuf;

   int16_t lf = strlen(formato);
   int16_t ln = strlen(numero); 

   pBuf = (char *)calloc(lf+1,1); //sizeof(char)*(lf+1));
   if (pBuf==NULL) return NULL;

   buffer = pBuf;
   int16_t i=lf, k=lf; 

   char c; 
   --lf; --ln; --k;
   while (lf>=0 && ln>=0) {
      c = formato[lf];
      if (c=='#') buffer[k] = numero[ln--]; 
      else buffer[k] = c;
      --k;
      --lf;
   }
   while (lf>=0) {
      c = formato[lf];
      if (*car) {
         if (c=='#') buffer[k] = *car;
         else buffer[k] = c;
      } else {
         buffer[k] = ' ';
      }
      --lf;
      --k;
   }
   buffer[i]='\0';
  
   return pBuf;
}

char *fun_xmoney (double numero, const char *tipo, const char *cblanc, uint16_t decimales, uint16_t pad){
   char *buf,*buffer,*cnum,*Retnum;
   const char * d, * s;
   uint16_t isize=0, ipart=0, iresto=0, tpad=0, swSign=0, swDec=0;

   buffer = (char *)calloc (32,1); //sizeof(char *) * 24);
   if (buffer==NULL) return NULL;

   buf = buffer;
   
   if( numero < 0 ) {
   	   swSign=1;
   	   numero *= -1;
   }

   uint16_t size = sprintf(buf,"%.*lf",decimales, numero);

   if (decimales>0) {
      d = strstr(buf,".");
      if (d!=NULL) {
         isize = d - buf;  // obtengo parte entera.
         d++;   // tendrá el decimal
         swDec=1;
      } else isize = size;
   } else isize = size;

   int limite = swDec?size-(decimales+1):size;
   iresto = limite > 3 ? isize % 3:0;   // cuantos dígitos sobran
   ipart = (uint16_t) isize / 3; // cuántas particiones debo efectuar; ipart-1=núm de sep
   tpad = isize+(ipart-1)+decimales+2+strlen(tipo)+swSign;

 //  printf("\n**** [%s],len=%lu,size=%d, limite=%d, tpad=%d ****\n",buf,strlen(buf),size,limite,tpad);

   uint16_t blancos=0;

   if (pad < tpad) {
       pad = tpad;
   } else {
       blancos = pad - tpad;
      // if (isize%2!=0) ++blancos;
       if (decimales==0) ++blancos; // por el punto decimal
   }

   Retnum = (char *)calloc(pad+1,1); //sizeof(char *)*(pad+1));
   if (Retnum==NULL) return NULL;
   cnum = Retnum;
   
   strcpy(cnum,tipo);
   uint16_t i;

   for (i=0;i<blancos;i++) strncat(cnum,cblanc,strlen(cblanc));

   if( swSign ) strcat(cnum,"-");

   s = buf;

   // agrego el resto, de existir
   if (iresto>0) {
      strncat(cnum,s,iresto);
      strcat(cnum,",");
      s += iresto;  // avanza el puntero
   }
   // agrego la parte entera
   if (limite >= 3){
      for (i=0;i<ipart; i++) {
         strncat(cnum,s,3);
         if (i<ipart-1) strcat(cnum,",");
         s += 3;
      }
   }else{
      strncat(cnum,s,limite);
      s += limite;
   }
   if (decimales>0) {
      strcat(cnum,".");
      strncat(cnum,d,strlen(d));
   }
   cnum[strlen(cnum)]='\0';
   free(buf);

   return Retnum;
}

HB_FUNC( XFUNMONEY )
{
    double pA = hb_parnd( 1 ); // A = DOUBLE
    PHB_ITEM pB = hb_param( 2, HB_IT_STRING ); // B = TIPO MONEDA
    PHB_ITEM pD = hb_param( 3, HB_IT_STRING ); // D = RELLENO
    int pE = hb_parni( 4 ); // E = DECIMALES
    int pF = hb_parni( 5 ); // F = ANCHO PAD
    
    char * pBuffer, * pRet;
    pBuffer = (char *)fun_xmoney(pA, hb_itemGetCPtr( pB ), 
                                 hb_itemGetCPtr( pD ), pE, pF);
    if( pBuffer != NULL ){
       hb_retc( pBuffer );
    }else{
       pRet = (char*)calloc(2,1);
       strcpy(pRet,"0");
       hb_retc( pRet );
       free(pRet);
    }
    free(pBuffer);
}

HB_FUNC( XFUNMASK )
{
    PHB_ITEM pA = hb_param( 1, HB_IT_STRING ); // A = STRING 
    PHB_ITEM pB = hb_param( 2, HB_IT_STRING ); // B = MASCARA
    PHB_ITEM pD = hb_param( 3, HB_IT_STRING ); // D = CARACTER DE RELLENO
    
    char * pBuffer;
    pBuffer = (char *)fun_xmask(hb_itemGetCPtr( pB ), hb_itemGetCPtr( pD ), 
                               hb_itemGetCPtr( pA ) );
    if( pBuffer != NULL ){
       hb_retc( pBuffer );
    }else{
       // si no hay memoria, devuelve el mismo string
       hb_retc( hb_itemGetCPtr( pA ) );
    }
    free(pBuffer);
}

short int fun_istnumber(const char * AX){
  int DX;
  short int SW_M=0,SW_N=0,SW_P=0,retorne=1;

  while( (DX=*AX)!='\0'){
    if(DX=='-'){
       if (SW_N || SW_P || SW_M) {retorne=0;break;}
       SW_M=1;
    }else if (DX=='.'){
       if (!SW_N || SW_P) {retorne=0;break;}
       SW_P=1;
    }else if (isdigit(DX)) {SW_N=1;
    }else {retorne=0;break;}
    ++AX;
  }
  return retorne;
}

HB_FUNC( ISTNUMBER )  // esto debe ir!! llevar otros codigos semejante a "C"
{
  PHB_ITEM pText = hb_param(1,HB_IT_STRING);
  const char *AX = hb_itemGetCPtr( pText );
  
  hb_retnint(fun_istnumber(AX));
}

HB_FUNC ( D2E )
{
  double nDec = hb_parnd(1);
  double nPrecision = hb_parnd(2);
  char *buf;
  double nExp;
  int signo;
  signo=nDec<0?-1:1;
  if (signo<0) nDec *= -1;
  if( nDec == 0) nExp = 0;
  else if (fabs( nDec ) < 1)  nExp = (double)(int)( log10( nDec ) ) - 1;
  else
      nExp = (double)(int)( log10( fabs( nDec ) + 0.00001 ) );   /* 0.00001 == kludge */
             /* for imprecise logs */
  nDec /= pow(10, nExp );  //pow(10, nExp);
  if (hb_numRound( fabs( nDec ), nPrecision ) >= 10){
      nDec /= 10;
      nExp++;
  }
  //buf = (char *) calloc(sizeof(char)*19+1,1);
  buf = (char *) calloc(32,1);
  switch((int)nPrecision){
     case 1:case 2:case 3: 
         sprintf(buf,"%1.3fE%d",nDec*signo,(int)nExp); break;
     case 4: sprintf(buf,"%1.4fE%d",nDec*signo,(int)nExp); break;
     case 5: sprintf(buf,"%1.5fE%d",nDec*signo,(int)nExp); break;
     case 6: sprintf(buf,"%1.6fE%d",nDec*signo,(int)nExp); break;
     case 7: sprintf(buf,"%1.7fE%d",nDec*signo,(int)nExp); break; 
     case 8: sprintf(buf,"%1.8fE%d",nDec*signo,(int)nExp); break;
     case 9: sprintf(buf,"%1.9fE%d",nDec*signo,(int)nExp); break; 
     default: sprintf(buf,"%1.10fE%d",nDec*signo,(int)nExp); 
  }
  hb_retc( buf );
  free(buf);
}

HB_FUNC ( E2D )
{
   const char *linea = hb_parc(1);
   const char *buf;
   char *sMant;
   double nMant;
   int nExp,mant=0,signo;
   buf=linea;
   while(toupper(*buf)!='E') {
      mant++;
      ++buf;
   }
   nExp = atoi(++buf);
   sMant = (char *)calloc(mant+1,1);
   strncpy(sMant,linea,mant);
   sMant[mant]='\0';
   if (sMant[0]=='-') {
      signo=(-1); 
      sMant++;
   } else signo=1;
   nMant = atof(sMant);
 ///  printf("--> %f, %d, %d\n%f\n",nMant,nExp,signo, nMant * pow( (double)10, (double)nExp)*signo);
   hb_retnd ( nMant * pow( (double)10, (double)nExp)*signo );
}

HB_FUNC( ISNOTATION )  // esto debe ir!! llevar otros codigos semejante a "C"
{
  PHB_ITEM pText = hb_param(1,HB_IT_STRING);
 
  const char *AX = hb_itemGetCPtr( pText );
 // int LX = hb_itemGetCLen( pText );
  int DX;
  short int SW_E=0,SW_P=0,SW_S=0,retorne=1;

  DX=*AX;
  if (DX=='-') ++AX; 
  
  while( (DX=*AX)!='\0'){
    if(toupper(DX)=='E' ){
       if (!SW_E) SW_E=1;
       else {retorne=0;break;}
    }else if (DX=='.'){
       if (!SW_P) SW_P=1;
       else {retorne=0;break;}
    }else if (DX=='+' || DX=='-') {
       if (!SW_S) SW_S=1;
       else {retorne=0;break;}
    }else if (!isdigit(DX)) {retorne=0;break;}
    ++AX;
  }
  if (!SW_E || !SW_P) retorne=0;
  
  hb_retnint(retorne);
}

// nAvance:=GETINITFILE(inputFile,lini)
HB_FUNC( GETINITFILE )
{
   const char * cFile = hb_parc( 1 );
   unsigned int nIni  = hb_parni( 2 );

   
   FILE *fp;
   char ch;

   unsigned int nLin=0;
   unsigned long nTotCar=0;
   
 
      fp=fopen(cFile,"r");
      if (fp!=NULL){
         nLin = 0;
         while ((ch = fgetc(fp)) != EOF){
           if (ch == '\n'){
              ++nLin;
              if (nLin >= nIni-1){
                 ++nTotCar; // para que se salte el '\n'
                 break;
              }
           }
           ++nTotCar;
         }
         fclose(fp);
      }

   hb_retnl(nTotCar);
}

HB_FUNC( CUENTALINEAS )
{
   const char * pFile = hb_parc( 1 );

   FILE *fp;
   long nLin=0,nTotCar=0,nLong=0,noldLong=0;
   int sw_Enter=0,sw_Car=0;
   char ch;
   
   fp=fopen(pFile,"r");
   if (fp!=NULL){
      nLin = 0;
      while ((ch = fgetc(fp)) != EOF){
        if (ch == '\n'){
           sw_Enter=1;
           sw_Car=0;
           nLin++;
           if (noldLong < nLong) { // longitud máxima de la línea
              noldLong = nLong;
              nLong=0;
           }
        }else{
           sw_Enter=0;
           sw_Car=1;
           nLong++;
        }
        nTotCar++;
      }
      fclose(fp);
      if(sw_Enter==0 && sw_Car==1)
        ++nLin;
   }

   PHB_ITEM pCWM = hb_itemArrayNew( 3 );
   hb_arraySetNL( pCWM, 1, (long) nLin );
   hb_arraySetNL( pCWM, 2, (long) nTotCar );
   hb_arraySetNL( pCWM, 3, (long) noldLong );
   hb_itemReturnRelease( pCWM );
}

HB_FUNC( SPCUENTALINEAS )
{
   const char * pFile = hb_parc( 1 );

   FILE *fp;
   long nLin=0,nTotCar=0,nLong=0,noldLong=0;
   int sw_Enter=0,sw_Car=0;
   char ch;
   
   fp=fopen(pFile,"r");
   if (fp!=NULL){
      nLin = 0;
      while ((ch = fgetc(fp)) != EOF){
        if (ch == (char)13){
           sw_Enter=1;
           sw_Car=0;
           nLin++;
           if (noldLong < nLong) { // longitud máxima de la línea
              noldLong = nLong;
              nLong=0;
           }
        }else{
           sw_Enter=0;
           sw_Car=1;
           nLong++;
        }
        nTotCar++;
      }
      fclose(fp);
      if(sw_Enter==0 && sw_Car==1)
        ++nLin;
   }

   PHB_ITEM pCWM = hb_itemArrayNew( 3 );
   hb_arraySetNL( pCWM, 1, (long) nLin );
   hb_arraySetNL( pCWM, 2, (long) nTotCar );
   hb_arraySetNL( pCWM, 3, (long) noldLong );
   hb_itemReturnRelease( pCWM );
}

HB_FUNC( CMDSYSTEM )
{
  PHB_ITEM pText = hb_param(1,HB_IT_STRING);
  unsigned int pLen  = hb_parni( 2 );
  
  const char * string = hb_itemGetCPtr( pText );
  
  int ret,R;
  
  if(pLen==1){
     R=system("clear");
  }
  ret=system(string);
  if(pLen==1){
     R=system("echo \"Presss any key to continue...\"");
  }
  hb_itemClear( pText );
  hb_retni(ret);
}

HB_FUNC( GETLINEAS )
{
   PHB_ITEM pSTRING = hb_param( 1, HB_IT_STRING );
   long nTotal  = hb_parnl( 2 );
   long nTotCar  = hb_parnl( 3 );
   long nMax  = hb_parnl( 4 );

   PHB_ITEM pCWM = hb_itemArrayNew( nTotal ); // CWM
   const char * STRING = hb_itemGetCPtr( pSTRING );
   long i;
   long totalCar = 0;
   int swError=0;
   if (nMax<=0){
      nMax=1024;
   }
   for(i=0;i<nTotal;i++){
      char * cBuff = (char *)calloc(nMax+nMax,1);
      long j=0;
      while( totalCar <= nTotCar ) {
         ///printf("DATO----- [%c] %d \n",*STRING,(int)*STRING);
         if ( *STRING!='\n' /* || *STRING==(char)13 */){
           // printf("Asigna STRING...\n");
            if(j>nMax+nMax){
               
               swError=1;
               j=nMax+nMax-1;
               break;
            }
            cBuff[j++] = *STRING;
           // printf("Asignado!!...\n");
            ++totalCar;
            ++STRING;
         }else{
            ++totalCar;
            ++STRING;  // nos saltamos '\n'
            ///++STRING;
            break;
         }
      }
      if (swError) {
         hb_arraySetC( pCWM, i+1, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
         free ( cBuff );
         break;
      }
      if(j>=0){
         cBuff[j]='\0';
         const char * pBuffer = cBuff;
         hb_arraySetC( pCWM, i+1, (const char *) pBuffer );
   //               printf("Libera cBuff...\n");
         free ( cBuff );
         
   //               printf("Liberado!...\n");
      }else{ 
         hb_arraySetC( pCWM, i+1, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
         free( cBuff );
         break;
      }
      
   }
   
   hb_itemClear( pSTRING );
   hb_itemReturnRelease( pCWM );
}

HB_FUNC( N2COLOR )
{
   int iColor = hb_parnidef( 1, -1 );

   if( iColor >= 0x00 && iColor <= 0xff )
   {
      char szColorString[ 10 ];
      hb_gtColorsToString( &iColor, 1, szColorString, 10 );
      hb_retc( szColorString );
   }
   else
      hb_retc_null();
}

#pragma ENDDUMP

