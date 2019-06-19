/**********************************************************

   ED4XU editor de textos con lenguaje de macros propio
   
   Autor: Daniel Stuardo
   
   daniel.stuardo@gmail.com
   
   noviembre 2018, 2019.
   
   Editor hecho con Harbour 3.0 y ansi C. Parte del código
   escrito es una adaptación de código C Harbour, o un uso
   completo, y otra parte fue escrito por el autor en años
   anteriores, cuando no conocía Harbour y pensaba que no había
   conocido funciones de proceso de texto más geniales que las
   de Clipper.
   
   Dejo mucho código comentado, por que no lo uso, pero
   podría ser útil para alguien más.
   
   Agradecimientos a todos los mencionados en este programa
   cuyos aportes potenciaron a Xu.
   
   Si va a utilizar parte del código que no es Harobur y que
   es propiedad del autor, hágalo, pero mencione quién lo 
   escribió.
   
***********************************************************/
/*

busca codigos pep y obtiene su secuencia ADN asociada. Ejemplo:

tolin -f eukaryotes.pep -fw shitshit.txt 'newl @1(#+"\n") next pool @1(@1+#+"\n") next loop((at{">"}>0)) back {I," : "+@1}'
*/

#include "memoedit.ch"

REQUEST HB_LANG_ES
HB_LANGSELECT( "ES" )
REQUEST HB_CODEPAGE_UTF8
hb_cdpSelect( "UTF8" )

function main()

public _CR:=HB_OSNewline()
public STRING
public BUFFER:={}
public SWKEEPVACIO:=.F.
public SWBUFFER:=.F.
public SWRESET:=.F.
public SWRADIANES:=.F.
public SWNUEVALINEA:=.F.
public SWSENSITIVE:=.T.
public DEFTOKEN:=" "   // token por defecto.
public BUFFERLINEA:=128  // por defecto
public NUMPI:=3.14159265358979323846
public nRow:=1
public nColumn:=0
// archivos BIG y NEXT
public nSavePos,fp,nEol,TC,TOTALCAR,BUFFERLINEA,nITER
public SWBIG:=.F.
public SWSTOP:=.F.
public SWEOF:=.F.
public NUMTOK:=0
public SIZEVAR:=20

// array de punteros a funciones
public _funExec:=array(118)

_funExec[1]:=0
_funExec[2]:=0
_funExec[3]:=@funvar()
_funExec[4]:=@funmov()
_funExec[5]:=@funneg()
_funExec[6]:=0

_funExec[7]:=@funjnz()
_funExec[8]:=@funelse()
_funExec[9]:=@funendif()

_funExec[10]:=@funpool()
_funExec[11]:=@funloop()
_funExec[12]:=@funround()
_funExec[13]:=@funutf8()
_funExec[14]:=@funansi()

_funExec[15]:=@funcat()
_funExec[16]:=@funmatch()
_funExec[17]:=@funlenstr()
_funExec[18]:=@funsub()
_funExec[19]:=@funat()
_funExec[20]:=@funrange()
_funExec[21]:=@funat1()

_funExec[22]:=@funaf()
_funExec[23]:=@funrat()
_funExec[24]:=@funptrp()
_funExec[25]:=@funptrm()
_funExec[26]:=@funcp()
_funExec[27]:=@funtr()
_funExec[28]:=@funtr1()
_funExec[29]:=@funtr2()
_funExec[30]:=@funaf1()

_funExec[31]:=@funtk()
_funExec[32]:=@funletk()
_funExec[33]:=@funlet()
_funExec[34]:=@funcopy()
_funExec[35]:=0
_funExec[36]:=@fungloss()

_funExec[37]:=0  //@funrp()
_funExec[38]:=@funtri()
_funExec[39]:=@funltri()
_funExec[40]:=@funrtri()
_funExec[41]:=@funup()
_funExec[42]:=@funlow()

_funExec[43]:=@funtre()
_funExec[44]:=@funins()
_funExec[45]:=@fundc()
_funExec[46]:=@funrpc()
_funExec[47]:=@funone()
_funExec[48]:=@funrnd()
_funExec[49]:=@funtre1()
_funExec[50]:=@funtre2()

_funExec[51]:=@funval()
_funExec[52]:=@funstr()
_funExec[53]:=@funch()
_funExec[54]:=@funasc()
_funExec[55]:=@funlin()
_funExec[56]:=@funpc()
_funExec[57]:=@funpl()
_funExec[58]:=@funpr()

_funExec[59]:=@funmsk()
_funExec[60]:=@funmon()
_funExec[61]:=@funsat()
_funExec[62]:=@fundeft()
_funExec[63]:=@funif()
_funExec[64]:=@funifle()
_funExec[65]:=@funifge()
_funExec[66]:=0

_funExec[67]:=0
_funExec[68]:=@funand()
_funExec[69]:=@funor()
_funExec[70]:=@funxor()

_funExec[71]:=@funnot()
_funExec[72]:=@funbit()
_funExec[73]:=@funon()
_funExec[74]:=@funoff()
_funExec[75]:=@funbin()
_funExec[76]:=@funhex()
_funExec[77]:=@fundec() 
_funExec[78]:=@funoct()

_funExec[79]:=@funln() 
_funExec[80]:=@funlog()
_funExec[81]:=@funsqrt()
_funExec[82]:=@funabs()
_funExec[83]:=@funint()
_funExec[84]:=@funceil()
_funExec[85]:=@funexp()

_funExec[86]:=@funfloor()
_funExec[87]:=@funsgn()
_funExec[88]:=@funsin()
_funExec[89]:=@funcos()
_funExec[90]:=@funtan()
_funExec[91]:=@funinv()
//       "+","-","*","/","\","^","%","|","&",;   // O   93-101
_funExec[92]:=0   // libre NL
_funExec[93]:=@funplus()
_funExec[94]:=@funminus()
_funExec[95]:=@funmulti()
_funExec[96]:=@fundiv()
_funExec[97]:=@funidiv()
_funExec[98]:=@funpot()
_funExec[99]:=@funmodulo()
_funExec[100]:=@funaor()
_funExec[101]:=@funaand()
_funExec[102]:=@funshfr()
_funExec[103]:=@funshfl()
_funExec[104]:=@funoxor()

//       "<=",">=","<>","=","<",">"}  // P  102-107
_funExec[105]:=@funle()
_funExec[106]:=@funge()
_funExec[107]:=@funneq()
_funExec[108]:=@funequal()
_funExec[109]:=@funless()
_funExec[110]:=@fungreat()
_funExec[111]:=@funnext()   // next
_funExec[112]:=@funback()   // back
_funExec[113]:=@funtpc()   // TPC
_funExec[114]:=@funht()   // HT
_funExec[115]:=@funvt()   // VT
_funExec[116]:=@funeof()  // EOF
_funExec[117]:=@funenv()  // getENV 
_funExec[118]:=@funsay()  // say

/*_funExec[102]:=@funle()
_funExec[103]:=@funge()
_funExec[104]:=@funneq()
_funExec[105]:=@funequal()
_funExec[106]:=@funless()
_funExec[107]:=@fungreat()
*/
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
      ++iParam
   END   
else
   ayudaLinea()
   quit
end
/********/

public PATH_XU:=GETENV("PATH_XU")  // para el help. Si no encuentra, usa el dir actual

if alltrim(PATH_XU)==""
   PATH_XU:=_fileSeparator+CURDIR()+"/help/"
  /* fwrite(1,_CR,hb_UTF8tostr("Atención: debe declarar la variable de entorno PATH_XU"))
   fwrite(1,_CR,hb_UTF8tostr("          si quiere ejecutar desde cualquier parte del"))
   fwrite(1,_CR,hb_UTF8tostr("          sistema."))
   fwrite(1,_CR,hb_UTF8tostr("          Si está en Linux u OSX, hágalo así:"),_CR)
   fwrite(1,_CR,hb_UTF8tostr("                export PATH_XU=ruta-de-XU"),_CR)
   fwrite(1,_CR,hb_UTF8tostr("          Si está en Win8=Dows, hágalo así:"),_CR)
   fwrite(1,_CR,hb_UTF8tostr("                set PATH_XU=ruta-de-XU"),_CR)
   fwrite(1,_CR,hb_UTF8tostr("     donde:"),_CR)
   fwrite(1,_CR,hb_UTF8tostr("        ruta-de-XU = la ruta donde está guardada XU|ED4XU|TOLIN."),_CR)
   release all
   quit*/
else
   PATH_XU:=PATH_XU+"/"
end

/* CONFIGURA EJECUCION */
//if numParam>1
swMacro:=.F.
swInput:=.F.
swMInput:=.F.
swHelp:=.F.

nHEADVAR:=1

swInit:=0

swManual:=.F.
swComando:=.F.

swBuscaLinea:=.F.
swBuscaExacta:=.F.
swNoincluye:=.F.

nLenVar:=1
cBUSCASTR:=""
cCOMANDO:=""
cSTRINGFOO:=""
BUFFERLINEA:=1024
inputMultiple:={}
PATRONGREP:="grep -h -n -b"    // para opciones de busqueda GREP: sin nombre de archivo
FILEGREP:=""   // archivo de patrones
swFileGrep:=.F.
swFoo:=.F.
swTipoREE:=.F.
swTipoREP:=.F.
SWRAW:=.F.  // para leer archivos con símbolos especiales
/* VERIFICA SISTEMA OPERATIVO */
OSHost:=OS()
OPERATING_SYSTEM:=upper(alltrim(substr(OSHost,1,at(" ",OSHost))))

/********/

   for i:=1 to len(_arr_par)
      STRING:=_arr_par[i]
//      ? STRING
      if STRING=="-rad"
         SWRADIANES:=.T.

      elseif STRING=="-h"   // help
         swHelp:=.T.

      elseif STRING=="-d"  // define precision numerica
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-d' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         nPrecision:=val(_arr_par[++i])
         SET DECIMAL TO nPrecision
         nPrecision:=0
      
      elseif STRING=="-mem"   // establece numero de variables de memoria
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-mem' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         SIZEVAR:=val(_arr_par[++i])
         if SIZEVAR<0
            fwrite(1,_CR+"El Meke dice: Parametro '-mem': minimo requerido es cero."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
      elseif STRING=="-buf"   // establece un baffer maximo de lectura
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-buf' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         BUFFERLINEA:=val(_arr_par[++i])
         if BUFFERLINEA<100
            fwrite(1,_CR+"El Meke dice: Parametro '-buf': minimo requerido son 100 bytes (default=128)."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
      
      elseif STRING=="-dim"   // dimensiona el BUFFER
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-B' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         buff:=val(_arr_par[++i])
         if buff>0
            BUFFER:=ARRAY(buff)
            afill(BUFFER,"")
            nHEADVAR:=len(BUFFER)+1
         else
            fwrite(1,_CR+hb_utf8tostr("El Meke dice: Parametro '-dim': tamaño debe ser mayor o igual a 1.")+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         
      elseif STRING=="-B"    // valor para el BUFFER
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-B' incompleto."+_CR+;
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

      elseif STRING=="-M"  // archivo input multiples
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-M' incompleto."+_CR+;
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

      elseif STRING=="-c"   // procesa un comando del sistema operativo.
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-c' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         cCOMANDO:=_arr_par[++i]
         inputMultiple:={}
         aadd(inputMultiple,cCOMANDO)
         swInput:=.T.
         swComando:=.T.

      elseif STRING=="-E"  // es una expresion regular extendida
         if swFileGrep
            FILEGREP:=" -E"
         elseif swBuscaLinea .or. swBuscaExacta
            PATRONGREP += " -E"
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-E' debe saber antes si busca un patron."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         if swTipoREP
            swTipoREP:=.F.
            swTipoREE:=.T.
            PATRONGREP:=strtran(PATRONGREP,"-P","")
         end

      elseif STRING=="-P"  // es una expresion regular Perl
         if swFileGrep
            FILEGREP:=" -P"
         elseif swBuscaLinea .or. swBuscaExacta
            PATRONGREP += " -P"
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-P' debe saber antes si busca un patron."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         if swTipoREE
            swTipoREP:=.T.
            swTipoREE:=.F.
            PATRONGREP:=strtran(PATRONGREP,"-E","")
         end
      
    //  elseif STRING=="-a"   // crudo.
    //     SWRAW:=.T.
      elseif STRING=="-nfs"    // devuelve las lineas donde no se encuentre contenido el string
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-nfs' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         ctmp:=_arr_par[++i]
         if file(ctmp)  // es un archivo de patrones:
            if validFile(ctmp)
               FILEGREP:=" -f "+ctmp
               swFileGrep:=.T.
            else
               fwrite(1,_CR+"El Meke dice: Parametro '-nfs': el archivo no es valido."+_CR+;
                       "Tolin aborta."+_CR)
               quit
            end
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-nfs': no encuentro el archivo especificado."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         PATRONGREP += " -v"
         PATRONGREP:=strtran(PATRONGREP,"-w","")
         swBuscaLinea:=.T.
         swBuscaExacta:=.F.
         swNoincluye:=.T.
         
      elseif STRING=="-nss"    // devuelve las lineas donde no se encuentre contenido el string
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-nss' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         cBUSCASTR:=_arr_par[++i]
         swBuscaLinea:=.T.
         swBuscaExacta:=.F.
         swNoincluye:=.T.
      
      elseif STRING=="-nfw"   // busca un archivo de patrones completos
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-nfw' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         ctmp:=_arr_par[++i]
         if file(ctmp)  // es un archivo de patrones:
            if validFile(ctmp)
               FILEGREP:=" -f "+ctmp
               swFileGrep:=.T.
            else
               fwrite(1,_CR+"El Meke dice: Parametro '-nfw': el archivo no es valido."+_CR+;
                       "Tolin aborta."+_CR)
               quit            
            end
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-nfw': no encuentro el archivo especificado."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         PATRONGREP += " -w -v"
         swBuscaExacta:=.T.
         swBuscaLinea:=.F.
         swNoincluye:=.T.
                     
      elseif STRING=="-nsw"     // busca un string y devuelve sus líneas para proceso
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-nsw' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         cBUSCASTR:=_arr_par[++i]
         swBuscaExacta:=.T.
         swBuscaLinea:=.F.
         swNoincluye:=.T.

      elseif STRING=="-fs"     // busca un string y devuelve sus líneas para proceso
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-fs' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         ctmp:=_arr_par[++i]
         if file(ctmp)  // es un archivo de patrones:
            if validFile(ctmp)
               FILEGREP:=" -f "+ctmp
               swFileGrep:=.T.
            else
               fwrite(1,_CR+"El Meke dice: Parametro '-fs': el archivo no es valido."+_CR+;
                       "Tolin aborta."+_CR)
               quit            
            end
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-fs': no encuentro el archivo especificado."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
//         PATRONGREP += " -b"
         PATRONGREP:=strtran(PATRONGREP,"-w","")
         swBuscaLinea:=.T.
         swBuscaExacta:=.F.
         
      elseif STRING=="-ss"     // busca un string y devuelve sus líneas para proceso
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-ss' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         cBUSCASTR:=_arr_par[++i]
         swBuscaLinea:=.T.
         swBuscaExacta:=.F.
      
      elseif STRING=="-fw"     // busca un string y devuelve sus líneas para proceso
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-fw' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         ctmp:=_arr_par[++i]
         if file(ctmp)  // es un archivo de patrones:
            if validFile(ctmp)
               FILEGREP:=" -f "+ctmp
               swFileGrep:=.T.
            else
               fwrite(1,_CR+"El Meke dice: Parametro '-fw': el archivo no es valido."+_CR+;
                       "Tolin aborta."+_CR)
               quit            
            end
         else
            fwrite(1,_CR+"El Meke dice: Parametro '-fw': no encuentro el archivo especificado."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         PATRONGREP += " -w"
         swBuscaExacta:=.T.
         swBuscaLinea:=.F.

      elseif STRING=="-sw"     // busca un string y devuelve sus líneas para proceso
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-sw' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         cBUSCASTR:=_arr_par[++i]
         swBuscaExacta:=.T.
         swBuscaLinea:=.F.
      
      elseif STRING=="-si"     // busqueda case insensitive solo en GREP
         ////SWSENSITIVE:=.F.
         PATRONGREP += " -i"
      
      elseif STRING=="-s"   // mete un string cagón.
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-s' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         aadd(inputMultiple,"no-file")
         cSTRINGFOO:=_arr_par[++i]
         swFoo:=.T.
         
      elseif STRING=="-seed"   // añade semilla random
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-seed' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         HB_RANDOMSEED(val(_arr_par[++i]))
      
      elseif STRING=="-ts"   // separador de token
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-ts' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         DEFTOKEN:=_arr_par[++i]

      elseif STRING=="-f"  // archivo input
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '-f' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         inputFile:=_arr_par[++i]
         if lower(inputFile)=="foo"
            swFoo:=.T.
            swInput:=.T.
            inputMultiple:={}
            aadd(inputMultiple,inputFile)
         else
            
           // if validFile(inputFile)
               inputMultiple:={}
               aadd(inputMultiple,inputFile)
               swInput:=.T.
               swMInput:=.F.
          //  else
          //     fwrite(1,_CR+"Parametro '-f': el archivo no es valido."+_CR+;
          //                "Tolin aborta."+_CR)
          //     quit
          //  end
         end
      elseif STRING=="-" // archivo/script de macros
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '"+STRING+"' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         _file:=hb_utf8tostr(_arr_par[++i])
      elseif STRING=="-man"   // manual completo.
         swManual:=.T.    
      elseif STRING=="-t" .or. STRING=="-" // archivo/script de macros
         if i==len(_arr_par)
            fwrite(1,_CR+"El Meke dice: Parametro '"+STRING+"' incompleto."+_CR+;
                    "Tolin aborta."+_CR)
            quit
         end
         _file:=_arr_par[++i]
         if STRING=="-t"
            swMacro:=.T.
         end
      elseif substr(STRING,1,1)=="-"
         fwrite(1,_CR+"El Meke dice: Parametro '"+STRING+"' no reconocido."+_CR+;
                    "Tolin aborta."+_CR)
         quit
      else                 // asume script en linea.
         _file:=hb_utf8tostr(STRING)
      end
   end
//end


STRING:=""

if swManual
   muestraAyuda()
   quit
end

if swHelp
   ayudaLinea()
   quit
end

IF !swComando
   if swInput
      if !file(inputFile) .and. !swFoo
         fwrite(1,_CR+"El Meke dice: No existe el archivo de entrada '"+inputFile+"'"+_CR+_CR+"Tolin aborta"+_CR)
         quit
      end
   else
      if swMInput
         for i:=1 to len(inputMultiple)
            if !file(inputMultiple[i])
               fwrite(1,_CR+"El Meke dice: No existe el archivo de entrada '"+inputMultiple[i]+"'"+_CR+_CR+"Tolin aborta"+_CR)
               quit
            end
         end
      else
         if len(cSTRINGFOO)==0
            fwrite(1,_CR+"El Meke dice: No fue indicado un archivo de entrada"+_CR+"Use '-f input-file'."+_CR+_CR+"Tolin aborta"+_CR)
            quit
         end
      end
   end
END

if swMacro
   if !file(_file)
      fwrite(1,_CR+"El Meke dice: No existe el archivo de macros '"+_file+"'"+_CR+_CR+"Tolin aborta"+_CR)
      quit
   else  // lo carga
      _file:=memoread(_file)
   end
else
   if len(alltrim(_file))==0
      fwrite(1,_CR+"El Meke dice: No fue indicado un script o archivo de macros"+_CR+"Use '-t macro-file' para usar un archivo de macros."+_CR+_CR+"Tolin aborta"+_CR)
      quit
   end
end
   
/* PREPARA SCRIPT */
SWKEEPVACIO:=.F.
SWBUFFER:=.F.
SWRESET:=.F.
SWSINGLE:=.F.
if len(alltrim(_file))>1
   Q:=_CTRLL_OBTIENELISTA(_file)

   if len(Q)==0
      return NIL
   end
   R:=_CTRLL_EVALUA(Q[1],Q[2])
   if valtype(R)=="L"
      return NIL
   end
else
   SWSINGLE:=.T.
end
/*****************/

TMPTOKEN:=DEFTOKEN   // respaldo token global
   
FOR nFile:=1 to len(inputMultiple)

   inputFile:=inputMultiple[nFile]

IF !swComando

      if swFoo
         STRING:=cSTRINGFOO  // por si metio solo un string.
      end

ELSE  // comando del sistema
      if OPERATING_SYSTEM=="LINUX" 
         cBUFF:=FUNFSHELL(inputFile,3)
      elseif OPERATING_SYSTEM=="DARWIN"
         cBUFF:=FUNFSHELL(inputFile,3)
      end
      // nuevo inputFile:
      inputFile:="output_"+hb_ntos(int(hb_random(1000000)))+".temp"
      cLen:=len(cBUFF)
      xfp:=fcreate(inputFile,0)
      if ferror()==0
         fwrite(xfp,cBUFF,cLen)
         cBUFF:=""
         fclose(xfp)
      else
         fwrite(1,_CR+"El Meke dice: *** Error interno: comando no pudo ser satisfecho ***"+_CR)
         quit
      end
      SWBIG:=.T.
END
/********/

IF swFoo  //swComando .or. swFoo

   if SWSINGLE
      fwrite(1,STRING+_CR)
   else
      RX:=_EVALUA_EXPR(@R,STRING,1,@BUFFER,inputFile,1)

      escribeResultados(RX,valtype(RX))
      
   end
   //exit  // sale del ciclo principal
 
else  // SWBIG:  lee cada linea desde el archivo:
   /* LECTURA DEL ARCHIVO */
   SWBIG:=.T.
   
   swFound:=.F.
   // procesa parametro de busqueda

   if swBuscaLinea .or. swBuscaExacta
      if swFileGrep
         cBUFF:=FUNFSHELL(PATRONGREP+FILEGREP+" "+inputFile,3)
      else
         // solo debo armar la línea una sola vez.
         if nFile==1
            PATRONGREP += " -b"
            if swBuscaExacta
               PATRONGREP += " -w"
            end
            if swNoIncluye
               PATRONGREP += " -v"
            end
         end
         cBUFF:=FUNFSHELL(PATRONGREP+" "+cBUSCASTR+" "+inputFile,3)
      end

      //cBUFF:=alltrim(cBUFF)

      // obtiene deplazamientos
      
      if len(cBUFF)>0
         swFound:=.T.
         //cLen:=mlcount(cBUFF, BUFFERLINEA)  // no importa si corta: solo me interesan los desplazamientos
        // ? cBUFF
        // inkey(0)
         STRING:=GETLINEAS(cBUFF)
         cLen:=len(STRING)
         cBUFF:=""
       /*  for i:=1 to cLen
            ? STRING[i][1],STRING[i][2]
         end
         ? "cLen BUFF=",len(cBUFF)
         ? "cLen ARRR=",cLen
         
         quit*/
     //    ? cBUFF
     /* else
         
         fwrite(1,_CR+"*** No hay coincidencias para procesar ***"+_CR)
         quit*/
      end
    //  quit
   end
   // inicia proceso de tolin
   fp:=fopen(inputFile,0)
   if ferror()!=0
      fwrite(1,_CR+"El Meke dice: El archivo '"+inputFile+"' no puede abrirse."+_CR+_CR+"Tolin aborta."+_CR)
      quit
   end
   TOTALCAR:=fseek(fp,0,2)
  // TC:=0
   fseek(fp,0,0)
   
   CX:=SPACE(256)
   nITER:=1
   i:=1
 //  TIEMPO:=seconds()

   while .T.
      if swBuscaLinea .or. swBuscaExacta
         if swFound
            if i<=cLen
               //c:=alltrim(memoline(cBUFF,200,i))
               //nITER := val(token(c,":",1))
               //nOFFSET := val(token(c,":",2))
               nOFFSET:=STRING[i][2]
               nITER:=STRING[i][1]
               FSEEK(fp, nOFFSET, 0)
               ++i
            else
               fclose(fp)
               exit
            end
         else
            exit  // sale si no hubo match
         end
      end
      BX:=""
      
      nSavePos := FSEEK( fp, 0, 1 )
      //BX:=FREADSTR(fp,BUFFERLINEA) //FREADSPECIAL(fp,BUFFERLINEA)
      //BX:=left(BX,at(_CR,BX)-1)
      BX:=FREADSPECIAL(fp,BUFFERLINEA)
      nEol:=len(BX)+1  // debe contar los caracteres especiales para el FSEEK
      TC:=nSavePos + nEol   //TC+nEol
      FSEEK( fp, TC, 0 )  // nEol + 1 
      
      if TC > TOTALCAR
         fclose(fp)
         exit
      end 
      if HB_FEOF(fp)
         SWEOF:=.T.
         
      end
      //?"BX=",BX," SWEOF?=",SWEOF
      if SWSINGLE
         //fwrite(1,hb_strtoutf8(RX)+_CR)
         fwrite(1,BX+_CR)
      else
         //PROCESA BX
        // ? "ENTRA"
         RX:=_EVALUA_EXPR(@R,BX,@nITER,@BUFFER,inputFile,0)
         if !escribeResultados(RX,valtype(RX))
            fclose(fp)
            exit
         end
         if SWSTOP
            fclose(fp)
            exit
         end
      end
      //if TC > TOTALCAR
     /* if SWEOF
         ? "FIN DE LA LECTURA"
         fclose(fp)
         exit
      end
      ?"PASO IGUAL" */
      ++nITER
      DEFTOKEN:=TMPTOKEN   // reseteo token global
   end
   fclose(fp)
 //  ? "TOTAL=",seconds()-TIEMPO
   if swComando
      if ".temp" $ inputFile  // evito errores como -c prog.c
         FERASE (inputFile)
      end
   end

end // SWBIG
CX=""
if SWRESET
   if len(BUFFER)>=nHEADVAR
      tARCHIVO:=substr(inputFile,rat("/",inputFile)+1,len(inputFile))+".buffer"
      if !SAVEFILE(BUFFER,tARCHIVO,LEN(BUFFER),nHEADVAR)
         _ERROR("EL MEKETREFE DICE: NO FUE POSIBLE GUARDAR EL CONTENIDO DEL BUFFER")
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
SWSTOP:=.F.    // resetea fin de proceso.
SWEOF:=.F.
DEFTOKEN:=TMPTOKEN   // reseteo token global

END  // for

/* VERIFICO si BUFFER tiene algo que guardar */
if !SWRESET
   if len(BUFFER)>=nHEADVAR
      if lower(inputFile)!="foo"
         tARCHIVO:=strtran(dtoc(date()),"/","")+"_"+strtran(time(),":","")+".buffer"
      else
         tARCHIVO:="foo.buffer"
      end
      if !SAVEFILE(BUFFER,tARCHIVO,LEN(BUFFER),nHEADVAR)
         _ERROR("EL MEKETREFE DICE: NO FUE POSIBLE GUARDAR EL CONTENIDO DEL BUFFER")
         quit
      end
   elseif nHEADVAR>0 .and. SWBUFFER  // imprimo las variables
     // ? "PASA ",len(BUFFER),",",nHEADVAR,",",SWBUFFER
      for i:=1 to len(BUFFER)
         if valtype(BUFFER[i])=="C"
            fwrite(1,BUFFER[i])
         else
            fwrite(1,hb_ntos(BUFFER[i]))
         end
         fwrite(1,_CR)
      end
     // fwrite(1,_CR)
   end
end


return NIL

/** funciones Harbour **/

function escribeResultados(RX,cType)

if cType=="C"
   RX:=strtran(RX,chr(0),"")
   if len(RX)>0  
         fwrite(1,hb_strtoutf8(RX)+_CR)
         return .t.
   else
         if SWKEEPVACIO
            fwrite(1,_CR)
         end
         return .T.
   end
elseif cType=="N"
   if RX==0
      if SWKEEPVACIO
         fwrite(1,"0"+_CR)
      end
      return .T.
   else
      IF ABS(RX)>INFINITY().or. (ABS(RX)>0.and.ABS(RX)<0.000000000001)
         RX:=D2E(RX,5)
      else
         RX:=alltrim(str(RX))
      end
      fwrite(1,RX+_CR)
      return .T.
   end
else
   return .F.  // porque hubo error
end


procedure ayudaLinea()
   fwrite(1,("         ,-----.      ______      _ ")+_CR)
   fwrite(1,("   /\j__/\  (  \`--.    ||   ___  ||       |\   ||")+_CR)
   fwrite(1,("   \`@_@'/  _)  >--.`.  ||  /   \ ||    /  ||\  ||")+_CR)
   fwrite(1,("  _{.:Y:_}_{{_,'    ) ) ||  |   | ||    |  || \ ||")+_CR)
   fwrite(1,(" {_}`-^{_} ```     (_/  ||  \___/ \|___ |  ||  \||  Versión Alfa.")+_CR)
   fwrite(1,_CR+"Modo de uso:"+_CR+;
   " tolin [-cdBFM][-man][-ts 'sep'][-seed][-ss|sw|si|nss|nsw 'patron'][-rad] [-fs|fw|nfs|nfw PATRON-file]"+_CR+;
   "       [-buf n] -f [path]file-input | foo"+_CR+; 
   "       <-t [path]filemacro | 'script-macro'> [> file][| commando]"+_CR+_CR)
   fwrite(1,("   -man        manual de funciones y operadores de macros Tolin.")+_CR+_CR)
   fwrite(1,("  Consulte 'tolin -man' por opciones, funciones macros y ejemplos.")+_CR+_CR)
   fwrite(1,("  AUTOR.")+_CR)
   fwrite(1,("           Mr. Dalien, mayo de 2019. daniel.stuardo@gmail.com")+_CR)
   fwrite(1,("           Harbour 3.0 (GPL 2.0 compatible), GCC (GNU).")+_CR)
   fwrite(1,("           Tolin Licencia GPL 2.0. Bugs, consultas, al mail.")+_CR+_CR)
return

procedure muestraAyuda()
local TLINEA,SLINEA,cVAR,MSGTOTAL,cBUSCA,nPos,LISTAFOUND,oldBUSCA,tfound,nInc
   setcursor(0)
   TLINEA:=MAXROW()
   SLINEA:=MAXCOL()
   if !file(PATH_XU+"tolin.help")
      fwrite(1,_CR+"No encuentro el archivo 'tolin.help'."+_CR+;
               "Si no ha instalado XU, asegurese de tener 'tolin.help' en el directorio 'help'"+_CR+;
               "dentro del directorio donde ha copiado Tolin, y declare la variable de entorno"+_CR+;
               "de la siguiente manera: "+_CR+_CR+"   export PATH_XU=<ruta-de-tolin>"+_CR+_CR)
      quit
   end
   cVAR:=hb_utf8tostr(MEMOREAD(PATH_XU+"tolin.help"))
   MSGTOTAL:="AYUDA DE MACROS - TOLIN  | ^C=Av Pag. ^R=Re Pag. ^N=Search ^K=Next ^J=Before"
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
      //setcolor( 'GR+/N,N/GR+,,,W/N' )
      setcolor( 'W/N,N/W,,,W/N' )
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
      end
   end
   setcursor(1)
   clear

return

function validFile(inputFile)
local cBUFF

  if OPERATING_SYSTEM=="LINUX" 
     cBUFF:=FUNFSHELL("file -i "+inputFile,3)
  elseif OPERATING_SYSTEM=="DARWIN"
     cBUFF:=FUNFSHELL("file -I "+inputFile,3)
  end
  cBUFF:=STRTRAN(cBUFF,HB_OSNEWLINE(),"")
  cBUFF:=SUBSTR(cBUFF,AT("=",cBUFF)+1,LEN(cBUFF))
  if cBUFF=="binary"
     return .F.
  end
return .T.

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
     STRING:=strtran(STRING,"\n",HB_OSNEWLINE())
     FWRITE(FP,STRING,LEN(STRING))
     ++LIN
  END
  FCLOSE(FP) 

RETURN .T.

FUNCTION _CTRLL_OBTIENELISTA(DX)
LOCAL Q,i,j,c,fun,ctap:=0,num,R,str,long,k,cTMP,sw,tmpi:=0,ctmpi:=0,ctpar:=0,strfun:="",SWFUN:=.F.
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

if "next" $ DX .and. !("eof" $ DX)
   _ERROR("EL CHOLITO DICE: DEBE USAR 'EOF' SI QUIERE USAR 'NEXT'")
   RETURN {}   
end

/* algunos reemplazos necesarios */
if "VOID" $ DX
   SWKEEPVACIO:=.T.
   DX:=strtran(DX,"VOID","")
end
if "BUFF" $ DX
   SWBUFFER:=.T.
   DX:=strtran(DX,"BUFF","")
end
if "RESET" $ DX
   SWRESET:=.T.
   DX:=strtran(DX,"RESET","")
end
if "NOSEN" $ DX
   SWSENSITIVE:=.F.
   DX:=strtran(DX,"NOSEN","")
end
if "_alpha_" $ DX
   DX:=strtran(DX,"_alpha_",hb_utf8tostr(chr(34)+"abcdefghijklmnñopqrstuvwxyz"+chr(34)))
end
if "_ALPHA_" $ DX
   DX:=strtran(DX,"_ALPHA_",hb_utf8tostr(chr(34)+"ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"+chr(34)))
end
if "_number_" $ DX
   DX:=strtran(DX,"_number_",chr(34)+"0123456789"+chr(34))
end

////DX:=strtran(DX,"?(","IF(")
DX:=strtran(DX,"match{","MATCH(#,")
//DX:=strtran(DX,"(--","(")
DX:=strtran(DX,"(-","(0-")  // ajusto negativos
//DX:=strtran(DX,"(++","INC(")
DX:=strtran(DX,"ins{","INS(#,")
DX:=strtran(DX,"range{","RANGE(#,") 
///DX:=strtran(DX,"#{","LIN(")  // linea
DX:=strtran(DX,"trea{","TREA(#,")
DX:=strtran(DX,"treb{","TREB(#,")
DX:=strtran(DX,"tre{","TRE(#,")
//DX:=strtran(DX,"{","CH(")  // chr
//DX:=strtran(DX,"&{","ASC(")  // asc
DX:=strtran(DX,"{*","CP(#,")
///DX:=strtran(DX,"rp{","RP(#,")   // ya no. reemplaza la linea de aquí en adelante.
DX:=strtran(DX,"{+","PTRP(#,")  // avanza puntero del string
DX:=strtran(DX,"{-","PTRM(#,")  // retorcede puntero extremo de string
DX:=strtran(DX,"mon{","MON(#,")
//DX:=strtran(DX,"${","TK(#,")
DX:=strtran(DX,"round{","ROUND(#,")
DX:=strtran(DX,"sub{","SUB(#,")
DX:=strtran(DX,"tra{","TRA(#,")
DX:=strtran(DX,"trb{","TRB(#,")
DX:=strtran(DX,"tr{","TR(#,")
DX:=strtran(DX,"rpc{","RPC(#,")
DX:=strtran(DX,"pc{","PC(#,")
DX:=strtran(DX,"pr{","PR(#,")
DX:=strtran(DX,"pl{","PL(#,")
DX:=strtran(DX,"msk{","MSK(#,")
DX:=strtran(DX,"sat{","SAT(#,")
DX:=strtran(DX,"rat{","RAT(#,")
DX:=strtran(DX,"ata{","ATA(#,")
DX:=strtran(DX,"afa{","AFA(#,")
DX:=strtran(DX,"at{","AT(#,")
DX:=strtran(DX,"af{","AF(#,")
DX:=strtran(DX,"dc{","DC(#,")
DX:=strtran(DX,"one{","ONE(#,")
DX:=strtran(DX,"tpc{","TPC(#,")
DX:=strtran(DX,"tklet{","TKLET(#,")

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
   if SWFUN
      if c!="("
         _ERROR("EL CHOLITO DICE: DEBE IR UN PARENTESIS AQUI: "+substr(DX,1,i)+"<<")
         RETURN {}
      end
   end
   if c=="("
      if SWFUN
         SWFUN:=.F.
      end
      AADD(Q,c)
      AADD(R,c)
      ++ctap
   elseif  c==")"
      AADD(Q,c)
      AADD(R,c)
      --ctap
      if ctap<0
         _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
         RETURN {}
      end
   elseif c==">"
      c+=substr(DX,++i,1)
      if c==">>"   // desplazamiento derecha
         AADD(Q,c)
         AADD(R,c)
      elseif c==">="
         AADD(Q,c)
         AADD(R,c)
      else
         c:=">"
         AADD(Q,c)
         AADD(R,c)
         --i
       //  _ERROR("EL CHOLITO DICE: SIMBOLO NO RECONOCIDO "+c)
      //   RETURN {}
      end
   elseif c=="!"
      c+=substr(DX,++i,1)
      if c=="!="   // distinto a 
         AADD(Q,"<>")
         AADD(R,"<>")
      else
         --i
      end
   elseif c=="<"
      c+=substr(DX,++i,1)
      if c=="<<"   // desplazamiento izquierda
         AADD(Q,c)
         AADD(R,c)
      elseif c=="<=" .or. c=="<>"
         AADD(Q,c)
         AADD(R,c)
      else
         c:="<"
         AADD(Q,c)
         AADD(R,c)
         --i 
       //  _ERROR("EL CHOLITO DICE: SIMBOLO NO RECONOCIDO "+c)
       //  RETURN {}
      end
   elseif c==chr(126)   // not
      AADD(Q,c)
      AADD(R,c)
   
   elseif c=="?"   // un IF má seguro y eficiente.  exp? expr-1 [: expr-2] . Salta hasta ":"
      AADD(Q,"JNZ"); AADD(R,"JNZ")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")

   elseif c==":"    // else
      AADD(Q,"ELSE"); AADD(R,"ELSE")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")

   elseif c==";" .or. c=="."  // endif
      AADD(Q,"ENDIF"); AADD(R,"ENDIF")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,")"); AADD(R,")")

   elseif c=="#"    // puede ser numero de línea de buffer si es acompañado de un numero #1, #3...
      tmpi:=i-1  // por si es una asignación
      ++i
      c:=substr(DX,i,1)
      if c=="{"   // es un indice compuesto
         num:=""
         ++i
         while i<=long
            c:=substr(DX,i,1)
            if c=="}"  // cierra composicion
               ++i
               exit
            end
            num+=c
            ++i
         end
         c:=substr(DX,i,1)
         if c=="("  // es una asignacion
            // busco hasta donde asigna:
            ctmpi:=i
            strfun:=c
            ++i
            //i+=2  // para saltarme primer "("
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"LET("+num+","+strfun+")"+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
            ///? "DX=",DX
         else   // es una linea
            DX:=substr(DX,1,tmpi)+"LIN("+num+")"+substr(DX,i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
           // ? "DX=",DX
         end
      else
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
         if len(num)==0  // es un parámetro de linea procesada.
            AADD(Q,"N")
            AADD(R,"#")

         elseif c=="("   // es una asignación
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"LET("+num+","+strfun+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
          //  ? "DX?=", DX; inkey(0)
         else
            if ISTNUMBER(num)!=1
               _ERROR("EL CHOLITO DICE: NUMERO DE LINEA NO VALIDO: "+substr(DX,1,i)+"<<")
               RETURN {}
            else
               AADD(Q,"LIN"); AADD(R,"LIN")
               AADD(Q,"("); AADD(R,"(")
               AADD(Q,"N");  AADD(R,val(num))
               AADD(Q,")"); AADD(R,")")
            end
         end
      end  // indice compuesto

/*   elseif c=="#"   // puede ser numero de línea de buffer si es acompañado de un numero #1, #3...
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
      else
         if ISTNUMBER(num)!=1
            _ERROR("EL CHOLITO DICE: NUMERO DE LINEA NO VALIDO: "+substr(DX,1,i)+"<<")
            RETURN {}
         end
         AADD(Q,"LIN"); AADD(R,"LIN")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,"N");  AADD(R,val(num))
         AADD(Q,")"); AADD(R,")")
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
         _ERROR("EL CHOLITO DICE: NUMERO DE TOKEN NO VALIDO: "+substr(DX,1,i)+"<<")
         RETURN {}
      end
      AADD(Q,"TK"); AADD(R,"TK")
      AADD(Q,"("); AADD(R,"(")
      AADD(Q,"N");  AADD(R,"#")
      AADD(Q,"N");  AADD(R,val(num))
      AADD(Q,")"); AADD(R,")")*/
   elseif c=="$"    // puede ser un token del tipo AWK $1, $2,...$n o un cambio de token $n(valor)
      tmpi:=i-1  // por si es una asignación
      ++i
      c:=substr(DX,i,1)
      if c=="{"   // es un indice compuesto
         num:=""
         ++i
         while i<=long
            c:=substr(DX,i,1)
            if c=="}"  // cierra composicion
               ++i
               exit
            end
            num+=c
            ++i
         end
         c:=substr(DX,i,1)
         if c=="("  // es una asignacion
            // busco hasta donde asigna:
            ctmpi:=i
            strfun:=c
            ++i
            //i+=2  // para saltarme primer "("
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"TKLET(#,"+num+","+strfun+")"+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
//            ? "DX=",DX
         else   // es una linea
            DX:=substr(DX,1,tmpi)+"TK(#,"+num+")"+substr(DX,i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
//            ? "DX=",DX
         end
      else
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
            _ERROR("EL CHOLITO DICE: NUMERO DE TOKEN NO VALIDO: "+substr(DX,1,i)+"<<")
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"TKLET(#,"+num+","+strfun+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
          //  ? "DX?=", DX; inkey(0)
         else
            AADD(Q,"TK"); AADD(R,"TK")
            AADD(Q,"("); AADD(R,"(")
            AADD(Q,"N");  AADD(R,"#")
            AADD(Q,"N");  AADD(R,val(num))
            AADD(Q,")"); AADD(R,")")
         end
      end
   elseif c=="@"    // variable de registro.
      tmpi:=i-1  // por si es una asignación
      ++i
      c:=substr(DX,i,1)
      if c=="{"   // es un indice compuesto
         num:=""
         ++i
         while i<=long
            c:=substr(DX,i,1)
            if c=="}"  // cierra composicion
               ++i
               exit
            end
            num+=c
            ++i
         end
         c:=substr(DX,i,1)
         if c=="("  // es una asignacion
            // busco hasta donde asigna:
            ctmpi:=i
            strfun:=c
            ++i
            //i+=2  // para saltarme primer "("
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"MOV("+num+","+strfun+")"+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
//            ? "DX=",DX
         else   // es una linea
            DX:=substr(DX,1,tmpi)+"VAR("+num+")"+substr(DX,i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "TKLET"
//            ? "DX=",DX
         end

      else
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
            _ERROR("EL CHOLITO DICE: NUMERO DE REGISTRO NO VALIDO: "+substr(DX,1,i)+"<<")
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
                     _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS: "+substr(DX,1,i)+"<<")
                     RETURN {}
                  end
               end
               ++i
            end
            DX:=substr(DX,1,tmpi)+"MOV("+num+","+strfun+substr(DX,++i,len(DX))
            long:=LEN(DX)
            i:=tmpi  // restauro indice para que lea "MOV"
            //  ? "DX?=", DX
         else
            AADD(Q,"VAR"); AADD(R,"VAR")
            AADD(Q,"("); AADD(R,"(")
            AADD(Q,"N");  AADD(R,val(num))
            AADD(Q,")"); AADD(R,")")
         end
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
         _ERROR("EL CHOLITO DICE: CADENA NO HA SIDO CERRADA: "+substr(DX,1,i)+"<<")
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
                 _ERROR("EL CHOLITO DICE: NUMERO BINARIO MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=BINTODEC(num)
        elseif c=="o"   // es octal
           for j:=1 to len(num)
              xt:=substr(num,j,1)
              if !(xt $ "01234567")
                 _ERROR("EL CHOLITO DICE: NUMERO OCTAL MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=OCTALTODEC(num)
        elseif c=="h"    // es hexadecimal
           for j:=1 to len(num)
              xt:=substr(num,j,1)
              if !(xt $ "0123456789ABCDEF")
                 _ERROR("EL CHOLITO DICE: NUMERO HEXADECIMAL MAL FORMADO: "+num)
                 RETURN {}
              end
           end
           num:=HEXATODEC(num)
        else   // no es ninguna hueá: error!
           _ERROR("EL CHOLITO DICE: BASE NUMERICA NO RECONOCIDA: "+num)
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
                 _ERROR("EL CHOLITO DICE: NO ES UN NUMERO NOTACION-CIENTIFICA VALIDO: "+num)
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
              _ERROR("EL CHOLITO DICE: NO ES UN NUMERO VALIDO: "+num)
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
               _ERROR("EL CHOLITO DICE: NO ES UN NUMERO NOTACION-CIENTIFICA VALIDO: "+num)
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
            _ERROR("EL CHOLITO DICE: NO ES UN NUMERO VALIDO: "+num)
            RETURN {}  // error
         else
            num:=val(num)
            IF ABS(num)>INFINITY().or. (ABS(num)>0.and.ABS(num)<0.000000000001)
               AADD(R,D2E(num))
            else
               AADD(R,num)
            end
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
         AADD(R,NUMPI)
      elseif fun=="I"
         AADD(Q,"I"); AADD(R,"I")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="NL"
         AADD(Q,"NL"); AADD(R,"NL")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="HT"
         AADD(Q,"HT"); AADD(R,"HT")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="VT"
         AADD(Q,"VT"); AADD(R,"VT")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="L"
         AADD(Q,"L"); AADD(R,"L")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="NEXT"
         AADD(Q,"NEXT"); AADD(R,"NEXT")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="BACK"
         AADD(Q,"BACK"); AADD(R,"BACK")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="DO"
         AADD(Q,"DO"); AADD(R,"DO")
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
      elseif fun=="EOF"   // total de tokens
         AADD(Q,"EOF"); AADD(R,"EOF")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="CLEAR"
         AADD(Q,"CLEAR"); AADD(R,"CLEAR")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
      elseif fun=="STOP"
         AADD(Q,"STOP"); AADD(R,"STOP")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")")
/*         AADD(Q,"FNK"); AADD(R,"FNK")
         AADD(Q,"("); AADD(R,"(")
         AADD(Q,")"); AADD(R,")") */
      else
         AADD(Q,fun)
         AADD(R,fun)
         SWFUN:=.T.
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
   elseif c=="+" .or. c=="-" .or. c=="*" .or. c=="/" .or. c=="^".or.c=="%".or.c=="\".or.c=="&".or.c=="|".or.c=="!" .or.c=="="
          
      AADD(Q,c)
      AADD(R,c)
   end
   ++i
end

if /*Q[len(Q)]!=")" .and. Q[LEN(Q)]!="N" .or.*/ ctap!=0
   _ERROR("EL CHOLITO DICE: PARENTESIS DESBALANCEADOS")
   RETURN {}
end
RETURN {Q,R}

FUNCTION _CTRLL_EVALUA(q,r)
LOCAL pila,pila2,p,p2,sw,l,l2,m,m2,swv,j,DICC,cFUN,o,h,x,y,posPila

/* codigo de funcion */

cFUN:={"FNA","FNA","FNA","FNA","FNA","FNA",;
       "FNB","FNB","FNB",;
       "FNC","FNC","FNC","FNC","FNC",;
       "FND","FND","FND","FND","FND","FND","FND",;
       "FNE","FNE","FNE","FNE","FNE","FNE","FNE","FNE","FNE",;
       "FNF","FNF","FNF","FNF","FNF","FNF",;
       "FNG","FNG","FNG","FNG","FNG","FNG",;
       "FNH","FNH","FNH","FNH","FNH","FNH","FNH","FNH",;
       "FNI","FNI","FNI","FNI","FNI","FNI","FNI","FNI",;
       "FNJ","FNJ","FNJ","FNJ","FNJ","FNJ","FNJ","FNJ",;
       "FNK","FNK","FNK","FNK",;
       "FNL","FNL","FNL","FNL","FNL","FNL","FNL","FNL",;
       "FNM","FNM","FNM","FNM","FNM","FNM","FNM",;
       "FNN","FNN","FNN","FNN","FNN","FNN","FNN",;
       "FNO","FNO","FNO","FNO","FNO","FNO","FNO","FNO","FNO","FNO","FNO","FNO",;
       "FNP","FNP","FNP","FNP","FNP","FNP",;
       "FNQ","FNQ","FNQ","FNQ","FNQ","FNQ","FNQ","FNQ"}

nFUN:={"FNA","FNB","FNC","FND","FNE","FNF","FNG","FNH","FNI","FNJ","FNK","FNL","FNM","FNN","FNO","FNP","FNQ"}  // "FNA-FNQ"

DICC:={"NT","I","VAR","MOV","~","L",;   // A
       "JNZ","ELSE","ENDIF",;   // B
       "DO","UNTIL","ROUND","UTF8","ANSI",;           // C
       "CAT","MATCH","LEN","SUB","AT","RANGE","ATA",;  // D
       "AF","RAT","PTRP","PTRM","CP","TR","TRA","TRB","AFA",;  // E
       "TK","TKLET","LET","COPY","FILE","GLOSS",;    // F     
       "RP","TRI","LTRI","RTRI","UP","LOW",;    // G
       "TRE","INS","DC","RPC","ONE","RND","TREA","TREB",;       // H
       "VAL","STR","CH","ASC","LIN","PC","PL","PR",;    // I
       "MSK","MON","SAT","DEFT","IF","IFLE","IFGE","CLEAR",; // J
       "STOP","AND","OR","XOR",;    // K
       "NOT","BIT","ON","OFF","BIN","HEX","DEC","OCT",; // L
       "LN","LOG","SQRT","ABS","INT","CEIL","EXP",;  // M
       "FLOOR","SGN","SIN","COS","TAN","INV","NL",;       // N- inv=91; NEWLINE se evalua aparte.
       "+","-","*","/","\","^","%","|","&",">>","<<","!",;   // O   93-104 (ex-101)
       "<=",">=","<>","=","<",">",;  // P 105-110 
       "NEXT","BACK","TPC","HT","VT","EOF","ENV","SAY"}   // Q  111-118
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
         if !es_simbolo(l) .and. !es_Lsimbolo(l)
////            ? l ; inkey(0)
            if es_funcion(l)
               aadd(pila,l)     // es funcion
               aadd(pila2,l2)
            else
               _ERROR("LA PERLA DICE: SIMBOLO NO RECONOCIDO >>"+l+"<<") //substr(l,2,len(l))+")")
               RETURN .F.
            end
         else
            if l=="("
               aadd(pila,l)
               aadd(pila2,l2)
            elseif l $ "+*-/^%\&|!" .or. l=="<<" .or. l==">>" .or. es_funcion(l) .or. es_Lsimbolo(l)
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
                    if isany(m,"^","*","/","%","\") //m =="^" .or. m=="*" .or. m=="/" .or. m=="%" .or. m=="\"
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

                  elseif isany(l,"/","%","\") //l=="/" .or. l=="\" .or. l=="%"
                    if isany(m,"^","*","/","%","\") //m=="*".or.m=="^".or.m=="/" .or. m=="%" .or. m=="\"
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
                
                  elseif isany(l,"+","-",">>","<<","&","|","!").or. es_Lsimbolo(l) 
                  //l=="+" .or. l=="-" .or. l==">>" .or. l=="<<" .or. l=="&".or.l=="|".or. l=="!".or. es_Lsimbolo(l)
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
            elseif l==")"        // es un parentesis derecho?
               m:=SDP(pila)        // extrae de pila para m
               m2:=SDP(pila2)
//               ? "M==",m
               while m!="(" 
                  aadd(p,m)        //mete m en p
                  aadd(p2,m2)
                  m:=SDP(pila)     // extrae de pila para m
                  m2:=SDP(pila2)
                  //?? m
                  if esnulo(m)   //m==nil
                      _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA")
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
   end
   
/*   for i:=1 to len(p)
      ? "CODE=",i," : ",p[i]
   end
   inkey(0) */
   
   // revisa sintacticamente todo.
   pila:={}

   posPila:=0
   while !empty(p)
      m:=SDC(p)
      ++posPila
      if m=="N" .or. m=="C" 
         aadd(pila,m)

      elseif m $ "+*-/^%\&|!".or.m=="<<".or.m==">>"  .or. es_Lsimbolo(m)
         o:=SDP(pila)
         n:=SDP(pila)
         if esnulo(n,o) //o==NIL .or. n==NIL // .or. o!="N" .or. n!="N" .and. (n!="X" .and. o!="X")
            _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA/TIPO DE OPERANDO OP: ( "+m+" )")
            RETURN .F.
         end
       /*  if !isany(n,"N","C") .or. !isany(o,"N","C") 
            _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. EXPRESION DEBE SER ENCERRADA ENTRE PARENTESIS OP: ( "+m+" )")
            RETURN .F.
         end*/
         aadd(pila,"N")

      elseif es_funcion(m)
         if substr(m,1,2)=="FN"  // no tiene que evaluar esto.
            loop
         end
         if m=="ROUND"
            o:=SDP(pila)
            n:=SDP(pila)
            if esnulo(n,o) //m==NIL .or. n==NIL ///.or. n!="N" .or. m!="N" .and. (n!="X" .and. m!="X")
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA/TIPO DE ARGUMENTO (ROUND)")
               RETURN .F.
            end
      /*      if !isany(n,"N","C") .or. !isany(o,"N","C") 
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. EXPRESION DEBE SER ENCERRADA ENTRE PARENTESIS OP: ( ROUND )")
               RETURN .F.
            end */
            aadd(pila,"N")

         elseif m=="MON"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            m:=SDP(pila)
            if esnulo(n,o,h,m) //h==NIL .or. n==NIL .or. o==NIL .or. m==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO (MON)")
               RETURN .F.
            end
          /*  if !isany(n,"N","C") .or. !isany(o,"N","C") .or. !isany(m,"N","C") .or. !isany(h,"N","C")
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. EXPRESION DEBE SER ENCERRADA ENTRE PARENTESIS OP: ( MON )")
               RETURN .F.
            end */
            aadd(pila,"C")

         elseif m=="TRB"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            y:=SDP(pila)  // ocurrencia
            if esnulo(n,o,h,y) //h==NIL .or. n==NIL .or. o==NIL .or. y==NIL 
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")

         elseif m=="TRA"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            y:=SDP(pila)  // ocurrencia
            x:=SDP(pila)  // reemplazos
            if esnulo(n,o,h,x,y) //h==NIL .or. n==NIL .or. o==NIL .or. y==NIL .or. x==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
            
         elseif isany(m,"TR","TPC")  //m=="TR" .or. m=="TPC"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o,h) //h==NIL .or. n==NIL .or. o==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")

         elseif m=="TREB"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            y:=SDP(pila)  // ocurrencia
            if esnulo(n,o,h,y) //h==NIL .or. n==NIL .or. o==NIL .or. y==NIL 
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
            
         elseif m=="TREA"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            y:=SDP(pila)  // ocurrencia
            x:=SDP(pila)  // reemplazos
            if esnulo(n,o,h,x,y) //h==NIL .or. n==NIL .or. o==NIL .or. y==NIL .or. x==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
            
         elseif m=="TRE"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o,h) //h==NIL .or. n==NIL .or. o==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")

         elseif m=="ATA"
            o:=SDP(pila)
            n:=SDP(pila)
            x:=SDP(pila)  // ocurrencia
            if esnulo(n,o,x) //o==NIL .or. n==NIL .or. x==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")  

         elseif m=="AT"
            o:=SDP(pila)
            n:=SDP(pila)
            if esnulo(n,o) //o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")        

         elseif m=="AFA"
            o:=SDP(pila)
            n:=SDP(pila)
            x:=SDP(pila)  // ocurrencia
            if esnulo(n,o,x) //o==NIL .or. n==NIL .or. x==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
            
         elseif m=="AF"
            o:=SDP(pila)
            n:=SDP(pila)
            if esnulo(n,o) //o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         
         elseif isany(m,"SUB","INS","RPC","IF","IFLE","IFGE","TKLET")
             //m=="SUB".or. m=="INS" .or. m=="RPC".or. m=="IF".or. m=="IFLE".or.m=="IFGE" .or.m=="TKLET"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o,h) //h==NIL .or. n==NIL .or. o==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")
         elseif m=="RANGE"
            h:=SDP(pila)
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o,h) //h==NIL .or. n==NIL .or. o==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         elseif m=="TK"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if esnulo(n,o) //o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         elseif isany(m,"CAT","CP","PTRP","PTRM","ONE","PL","PC","PR","MSK","SAT","DC")
            //  m=="CAT" .or. m=="CP".or.m=="PTRP".or.m=="PTRM" .or. m=="ONE".or. m=="PL".or.m=="PC".or.m=="PR".or.m=="MSK".or.m=="SAT" .or.m=="DC"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if esnulo(n,o) //o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"C")
            end
         elseif isany(m,"MATCH","AND","OR","XOR","RAT","BIT","ON","OFF")
              //m=="MATCH" .or. m=="AND" .or. m=="OR".or.m=="XOR".or.m=="RAT".or.m=="BIT".or.m=="ON".or.m=="OFF"
            o:=SDP(pila)
            n:=SDP(pila)
            
            if esnulo(n,o) //o==NIL .or. n==NIL// .or. n!="C" .or. m!="C"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         elseif isany(m,"UP","LOW","TRI","LTRI","RTRI","BIN","HEX","UTF8","ANSI")
            //m=="UP".or.m=="LOW".or.m=="TRI".or.m=="LTRI".or.m=="RTRI".or.m=="BIN".or.m=="HEX".or.m=="UTF8".or.m=="ANSI"
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C")

         elseif isany(m,"LET","MOV") 
            //m=="LET" .or. m=="MOV"
            h:=SDP(pila)
            n:=SDP(pila)
            if esnulo(n,h) //h==NIL .or. n==NIL
               _ERROR("LA PERLA DICE: FALTAN ARGUMENTOS EN "+m)
               RETURN .F.
            end

         elseif isany(m,"DEFT","UNTIL","RP","JNZ")
           //m=="DEFT" .or. m=="LOOP".or.m=="RP"
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: ESPERO UN ARGUMENTO VALIDO PARA ("+m+")")
               RETURN .F.
            end
         
         elseif isany(m,"DO","CLEAR","ELSE","ENDIF","NEXT","BACK","STOP")
            //m=="POOL" .or. m=="CLEAR" .or. m=="JNZ" .or. m=="ELSE" .or. m=="ENDIF".or. m=="NEXT".or.m=="BACK"
            ;
            
         elseif isany(m,"CH","STR","GLOSS","ENV")
            //m=="CH" .or. m=="STR" .or. m=="GLOSS"
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: ESPERO UN ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"C") // solo para que pase el analisis
         elseif isany(m,"LEN","ASC","RND","DEC","VAR","NOT")
            //m=="LEN".or. m=="ASC" .or. m=="RND".or.m=="DEC" .or. m=="VAR" .or. m=="NOT"
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         
         elseif m=="VAL"
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
            aadd(pila,"N")
         elseif isany(m,"FILE","NL","HT","VT")
            //m=="FILE".or.m=="NL".or. m=="HT".or.m=="VT"
            aadd(pila,"C")

         elseif isany(m,"COPY","SAY")
            n:=SDP(pila)
            if n==NIL
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO ("+m+")")
               RETURN .F.
            end
           
            
         elseif isany(m,"I","NT","L","EOF")
            //m=="I" .or. m=="NT".or.m=="L"  //.or.m=="LINEEND"
            aadd(pila,"N")
         else
            m:=SDP(pila)
            if m==NIL //.or. m!="N"
               _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA. FALTA ARGUMENTO O TIPO DISTINTO")
               RETURN .F.
            else
               aadd(pila,"N")
            end
         end
      else  // puede ser variable
         _ERROR("LA PERLA DICE: SIMBOLO NO RECONOCIDO ("+m+")")
         RETURN .F.
      end
   end
 
/* Añade codigos de funcion */
   
   i:=1 
   while i<=len(p2)
    //  ? "p2=",p2[i]
    if valtype(p2[i])=="C"
       _pos:=0
       for j:=1 to len(DICC)
          if p2[i]==DICC[j]
             _pos:=j //ascan(DICC,p2[i])
             exit
          end
       end
      
      if _pos>0
         p2[i]:=_pos   // meto código de funcion
         asize(p2,len(p2)+1)
         ains(p2,i)
         p2[i]:=ASCAN(nFUN,cFUN[_pos])  // intercalo codigo de familia
         ++i
         
      else   // es un string
         asize(p2,len(p2)+1)
         ains(p2,i)
         p2[i]:=20  // codigo de pushdata string
         ++i
      end

    else
         asize(p2,len(p2)+1)
         ains(p2,i)
         p2[i]:=21  // codigo de pushdata numero
         ++i
    end
      ++i
   end 


/*   for i:=1 to len(p2)
      ? "CODE=",i," : ",p2[i]
   end
   inkey(0)*/
   if len(pila)>1
      _ERROR("LA PERLA DICE: EXPRESION MAL FORMADA (QUEDAN "+hb_ntos(len(pila))+" RESULTADOS EN PILA).")
      RETURN .F.
   end 
RETURN p2


FUNCTION _EVALUA_EXPR(p,par,ITERACION,tBUFFER,FILENAME,ENDFILE)
LOCAL res,pila,m,n,o,h,x,y,k,i,j,id:=0,ids:=0,c1,c2,c3,str,nLength,xvar,ope:=0,vtip
LOCAL VARTABLE,JMP:={},LENJMP:=0,vn,vo,SWEDIT:=.F.,num,LENP,pilaif,tmpPos,swFound,tmpo,tmpn
LOCAL CX,tmpPar
//LOCAL tmpAT,tmpATF,swAF,swAT

   pila:={}
   pilaif:={}
   tmpPos:=0   // guarda la ultima posicion de RANGE, para busquedas iterativas, por linea
   
//   tmpAT:=0    // guarda ultima posicion de AT por linea.
//   tmpATF:=0   // idem para AF
//   swAF:=.F.   // si ya hizo una búsqueda en la linea.
//   swAT:=.F.
   VARTABLE:=ARRAY(SIZEVAR)
   afill(VARTABLE,"")
   NUMTOK:=numtoken(par,DEFTOKEN)
//   if pcount()==5
      SWEDIT:=.T.
//   end
   LENP:=len(p)
   //while !empty(p)
   for i:=1 to LENP
      if inkey()==27
         exit
      end
      //m:=SDC(p)
      m:=p[i]
    //  ? "DATA= ",m
      if m==20 //chr(1)   // mete string
         m:=p[++i]
         if m=="#"
            AADD(pila,par+chr(0))
         else
            aadd(pila,m)
         end
      elseif m==21 //chr(2)
         m:=p[++i]
         aadd(pila,m)   // numero
      else   // ejecuta funcion
         SWITCH m
 /*
      if valtype(m)=="C"
         if m=="#"
            AADD(pila,par+chr(0))
      //      ? "PARAM: ",par; inkey(0) 
   */         
         //elseif m=="FNO"
         //elseif m $ "+*-/^%|&\" .or. es_Lsimbolo(m)
 
         CASE 15 // "FNO"
            m:=p[++i]
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o)   //n==NIL .or. o==NIL
               _ERROR("LA MONA DICE: VALOR NULO EN OPERACION ARITMETICO-LOGICA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
               RETURN .F.
            end
            vn:=valtype(n)
            vo:=valtype(o)
            if vn=="C"
               if right(n,1)!=chr(0)  //!(chr(0) $ n)
                  c1:=alltrim(n)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     n:=val(c1)
                     vn:="N"
                  else
                     if ISNOTATION(c1)==1
                        n:=e2d(c1)
                        vn:="N"
                     end
                  end
                  end
               end
            end
            
            if vo=="C"
               if right(o,1)!=chr(0)  //!(chr(0) $ o)
                  c1:=alltrim(o)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     o:=val(c1)
                     vo:="N"
                  else
                     if ISNOTATION(c1)==1
                        o:=e2d(c1)
                        vo:="N"
                     end
                  end
                  end
               end
            end

//       "+","-","*","/","\","^","%","|","&",">>","<<","!";   // O   93-104

            if !(_funExec[m]:EXEC(@pila,@o,@n,@vo,@vn,par))
               return .F.
            end
            EXIT
            
         //elseif m=="FNP"
         CASE 16  // "FNP"
         //elseif m $ "+*-/^%|&\" .or. es_Lsimbolo(m)     
            m:=p[++i]   
            n:=SDP(pila)
            o:=SDP(pila)
            if esnulo(n,o)   //n==NIL .or. o==NIL
               _ERROR("LA MONA DICE: VALOR NULO EN OPERACION LOGICA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
               RETURN .F.
            end
            vn:=valtype(n)
            vo:=valtype(o)
            if vn=="C"
               if right(n,1)!=chr(0)  //!(chr(0) $ n)
                  c1:=alltrim(n)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     n:=val(c1)
                     vn:="N"
                  else
                     if ISNOTATION(c1)==1
                        n:=e2d(c1)
                        vn:="N"
                     end
                  end
                  end
               end
            end
            
            if vo=="C"
               if right(o,1)!=chr(0)  //!(chr(0) $ o)
                  c1:=alltrim(o)
                  if len(c1)>0
                  if ISTNUMBER(c1)==1
                     o:=val(c1)
                     vo:="N"
                  else
                     if ISNOTATION(c1)==1
                        o:=e2d(c1)
                        vo:="N"
                     end
                  end
                  end
               end
            end               

            vtip:=vo+vn
//       "<=",">=","<>","=","<",">"}  // P  102-107
            if !(_funExec[m]:EXEC(@pila,@o,@n,@vtip,@ITERACION))
               return .F.
            end
            EXIT

         //elseif m=="FNA"
         CASE 1  // "FNA"
            m:=p[++i]
            if m==1
               AADD(pila,NUMTOK) 
            elseif m==2
               AADD(pila,ITERACION) 
            elseif m==6
               AADD(pila,len(par))
            else
               if !(_funExec[m]:EXEC(@pila,@VARTABLE))
                  return .F.
               end
            end
            EXIT


         //elseif m=="FNB"
         CASE 2  // "FNB"
            m:=p[++i]
            if !(_funExec[m]:EXEC(@pila,@p,@i,@LENP))
               return .F.
            end
            EXIT

         //elseif m=="FNC"
         CASE 3  // "FNC"
            m:=p[++i]

            if !(_funExec[m]:EXEC(@pila,@JMP,@LENJMP,@LENP,@i))
               return .F.
            end
            EXIT
                     
         //elseif m=="FND"
         CASE 4  // "FND"
            m:=p[++i]
            if !(_funExec[m]:EXEC(@pila))
               return .F.
            end
            EXIT
         
         //elseif m=="FNE"
         CASE 5  // "FNE"
            m:=p[++i]
            if !(_funExec[m]:EXEC(@pila))
               return .F.
            end
            EXIT  

         //elseif m=="FNF"
         CASE 6  // "FNF"
            m:=p[++i]
            if m==35 // FILE
               AADD(pila,FILENAME+chr(0))
            else
             //  ? "FNF M=",m,"  fun=",_funExec[m]
               if !(_funExec[m]:EXEC(@pila,@tBUFFER))
                  return .F.
               end
            end
            EXIT
         
         //elseif m=="FNG"
         CASE 7
            m:=p[++i]
            if m==37  // reemplaza el parametro por un nuevo valor
               o:=SDP(pila)
               if valtype(o)=="N"
                  o:=hb_ntos(o)
               else
                  o:=strtran(o,chr(0),"")
               end
               
               ///AADD(pila,o)
               par:=o
               NUMTOK:=numtoken(par,DEFTOKEN)
               loop
            end
            if !(_funExec[m]:EXEC(@pila))
               return .F.
            end
            EXIT
               
         //elseif m=="FNH"
         CASE 8   
            m:=p[++i]
            if !(_funExec[m]:EXEC(@pila))
               return .F.
            end
            EXIT

         //elseif m=="FNI"
         CASE 9
            m:=p[++i]
          //  ? "FNI M=",m,"  fun=",_funExec[m]
            if !(_funExec[m]:EXEC(@pila,@tBUFFER))
               return .F.
            end
            EXIT            
               
         //elseif m=="FNJ"
         CASE 10
            m:=p[++i]
            if m==66  // debe salir con CLEAR
               asize(tBUFFER,0)
               exit
            else
               if !(_funExec[m]:EXEC(@pila))
                  return .F.
               end
               NUMTOK:=numtoken(par,DEFTOKEN)
            end
            EXIT
                
         //elseif m=="FNK"
         CASE 11
            m:=p[++i]
            if m==67   // stop
               ///AADD(pila,"")
               hb_keyPut(27)
               SWSTOP:=.T.
               loop
            else  
               if !(_funExec[m]:EXEC(@pila))
                  return .F.
               end
            end
            EXIT
         
         //elseif m=="FNL"
         CASE 12
            m:=p[++i]
            if !(_funExec[m]:EXEC(@pila))
               return .F.
            end
            EXIT

         //elseif m=="FNM"
         CASE 13
            m:=p[++i]
            n:=SDP(pila)
            if esnulo(n)   //n==NIL
               FUN:=IIF(m==79,"LN",iif(m==80,"LOG",iif(m==81,"SQRT",iif(m==82,"ABS",iif(m==83,"INT []",iif(m==84,"CEIL","EXP"))))))
               _ERROR("LA MONA DICE: VALOR NULO EN "+FUN+_CR+"Quizas no encerraste una expresión entre paréntesis")
               RETURN .F.
            end
            if valtype(n)!="N"
               n:=alltrim(n)
               n:=strtran(n,chr(0),"")
               if ISTNUMBER(n)==1
                  n:=val(n)
               elseif ISNOTATION(n)==1
                  n:=e2d(n)
               else
                  _ERROR("LA MONA DICE: OPERANDO NO ES UN NUMERO "+n)
                  RETURN .F.
               end
            end
            if !(_funExec[m]:EXEC(@pila,n))
               return .F.
            end
            EXIT

         //elseif m=="FNN"
         CASE 14
            m:=p[++i]
            if m==92
               AADD(pila,_CR+chr(0))
               EXIT
            end
            n:=SDP(pila)
            if esnulo(n)   //n==NIL
               FUN:=IIF(m==86,"FLOOR",iif(m==87,"SGN",iif(m==88,"SIN",iif(m==89,"COS",iif(m==90,"TAN","INV")))))
               _ERROR("LA MONA DICE: VALOR NULO EN "+FUN+_CR+"Quizas no encerraste una expresión entre paréntesis")
               RETURN .F.
            end
            if valtype(n)!="N"
               n:=alltrim(n)
               n:=strtran(n,chr(0),"")
               if ISTNUMBER(n)==1
                  n:=val(n)
               elseif ISNOTATION(n)==1
                  n:=e2d(n)
               else
                  _ERROR("LA MONA DICE: OPERANDO NO ES UN NUMERO "+n)
                  RETURN .F.
               end
            end
            if !(_funExec[m]:EXEC(@pila,n))
               return .F.
            end
            EXIT
         
         CASE 17   // "FNQ"
            m:=p[++i]
            
            if !(_funExec[m]:EXEC(@pila,@par,@ITERACION))
               return .F.
            end
         END
      end   
      /*   else
            aadd(pila,m)
         end
      elseif valtype(m)=="N"
         aadd(pila,m)
      end */
   end

   XLEN:=len(pila)
   if XLEN>1 
      _ERROR("LA MONA DICE: EXPRESION MAL FORMADA (QUEDAN "+hb_ntos(len(pila))+" RESULTADOS EN PILA).")
      RETURN .F.
   end

RETURN iif(XLEN>=1,pila[XLEN],"")

FUNCTION GLOSA(CIFRA)
LOCAL cDec,cNum,xPos,c,c1,c2,cCIF,decimal,num,N,desde,name,cif,l,i
LOCAL AX,BX,CX,DX,EX,FX
AX:={"uno","dos","tres","cuatro","cinco","seis","siete","ocho","nueve"}
BX:={"once","doce","trece","catorce","quince","dieciseis","diecisiete","dieciocho","diecinueve"}
CX:={"","veinti","treinta y ","cuarenta y ","cincuenta y ","sesenta y ","setenta y ","ochenta y ","noventa y "}

DX:={"diez","veinte","treinta","cuarenta","cincuenta","sesenta","setenta","ochenta","noventa"}

FX:={"ciento","docientos","trecientos","cuatrocientos","quinientos","seicientos","setecientos","ochocientos","novecientos"}

EX :={"","mil","millones","mil millones","billones","mil billones","trillones","mil trillones","cuatrillones","mil cuatrillones",;
      "quintillones","mil quintillones","sextillones","mil sextillones","septillones","mil septillones","octillones","mil octillones",;
      "nonillones","mil nonillones","decillon","mil decillones"}

if ISNOTATION(CIFRA)==1
   cNum:=alltrim(str(E2D(CIFRA)))
else
   cNum:=alltrim(CIFRA)
end

if ISTNUMBER(cNum)==1
   cDec:=""
   xPos:=at(".",cNum)
   if xPos>0
      cDec:=substr(substr(cNum,xPos+1,len(cNum)),1,2)
      cNum:=substr(cNum,1,xPos-1)
   end

   decimal:=""
   if val(cDec)>0
      if cDec!="00"
         decimal:=" con "
         num:=val(cDec)
         if num<10
            decimal+=AX[num]
         elseif num<20
            //num:=hb_ntos(num)
            if cDec=="10"
               decimal+="diez"
            else 
               decimal+=BX[val(right(cDec,1))]
            end
         else
            //c:=hb_ntos(num)
            if val(substr(cDec,2,1))==0
               decimal+=DX[val(left(cDec,1))]
            else
               c1:=val(right(cDec,1))
               //if c1>1
                  decimal+=CX[val(left(cDec,1))]+AX[c1]
              // else
              //    N+=CX[val(left(c,1))]+"un "+name
              // end
            end
         end
      end
   end
 //  ? decimal
   l:=len(cNum)
   cif:={}
   while l>0
      if l-2>0
         aadd(cif,val(substr(cNum,l-2,l)))
      else
         aadd(cif,val(substr(cNum,1,l)))
      end
      cNum:=substr(cNum,1,l-3)
      l:=len(cNum)
   //   ? cif[len(cif)]
   end
   desde:=l:=len(cif)
   nCIF:=""

   for i:=l to 1 step -1
      c:=cif[i]
      N:=""
      if c>0
         if desde>0
            name:=EX[desde]+" "
         else
            name:=""
         end
         
         if c<10
            if c==1 
               if desde>=2
                //  c2:=at("(",name)
                //  if c2>0
                //     N+="un "+left(name,c2-1)+" "
                //  else
                   if name!="mil "
                     c2:=at("es",name)
                     if c2>0
                        N+="un "+left(name,c2-1)+" "
                     else
                        N+="un "+name
                     end
                   else
                     N+=name  
                   end
               else
                  N+="uno" //+name
               end
            else
               N+=AX[c]+" "+name
            end
         elseif c<20
            c:=hb_ntos(c)
            if c=="10"
               N+="diez "+name
            else 
               N+=BX[val(right(c,1))]+" "+name
            end
         elseif c<100
            c:=hb_ntos(c)
            if val(substr(c,2,1))==0
               N+=DX[val(left(c,1))]+" "+name
            else
               c1:=val(right(c,1))
               if c1>1
                  N+=CX[val(left(c,1))]+AX[c1]+" "+name
               else
                  if desde>=2
                     N+=CX[val(left(c,1))]+"un "+name
                  else
                     N+=CX[val(left(c,1))]+"uno"
                  end
               end
            end
         else   // mayor que 100
            c:=hb_ntos(c)
            if val(substr(c,2,len(c)))==0
               if left(c,1)=="1"
                  N+="cien "+name
               else
                  N+=FX[val(left(c,1))]+" "+name
               end
            else   
               N+=FX[val(left(c,1))]+" "
               c:=substr(c,2,2)
               c1:=val(c)
          //  ? c1
               if c1<10
                  if c1==1 
                     if desde>=2
                        c2:=at("es",name)
                        if c2>0
                           N+="un "+left(name,c2-1)+" "
                        else
                        
                           N+="un "+name
                        end
                     else
                        N+="uno "//+name
                     end
                  else
                    // ? c1
                     N+=AX[c1]+" "+name
                  end
               elseif c1<20
                  if c=="10"
                     N+="diez "+name
                  else 
                     N+=BX[val(right(c,1))]+" "+name
                  end
               elseif c1<100
                  if val(substr(c,2,1))==0
                     N+=DX[val(left(c,1))]+" "+name
                  else
                     c2:=val(right(c,1))
                     if c2==1
                        if desde>=2
                           N+=CX[val(left(c,1))]+"un "+name
                        else
                           N+=CX[val(left(c,1))]+"uno"
                        end
                     else
                        N+=CX[val(left(c,1))]+AX[c2]+" "+name
                     end
                  end
               end
            end  
         end
      else
         if l==1
            N+="cero"
         end
      end
      if desde>2
         if cif[i-1]>0
            if rat("mil ",N)>0
               N:=substr(N,1,rat("mil ",N)+3)
            end
         end
      end
      nCIF:=nCIF+N
      --desde
   end
   nCIF:=alltrim(nCIF)+decimal

else
   nCIF:= " ** no se puede convertir ["+cNum+"] ** " 
end

RETURN nCIF


/****** FUNCIONES DEL LENGUAJE *******/


function funht(pila)  
   AADD(pila,chr(9)+chr(0))
return .T.

function funvt(pila)
   AADD(pila,chr(11)+chr(0))
return .T.

function funtpc(pila)   // TPC
local h,n,o
   h:=SDP(pila)
   n:=SDP(pila) 
   o:=SDP(pila)
   if valtype(h)!="N"
      h:=val(h)
   end
   if valtype(n)=="N"
      n:=hb_ntos((n))
   else
      n:=strtran(n,chr(0),"")
   end
   if valtype(o)=="N"
      o:=hb_ntos((o))
   else
      o:=strtran(o,chr(0),"")
   end
   AADD(pila, POSCHAR(o,n,h)+chr(0))
return .T.

function funeof(pila)
   AADD(pila,iif(SWEOF,0,1))
return .T.

function funenv(pila)
local n
   n:=SDP(pila) 
   if valtype(n)=="N"
      n:=hb_ntos((n))
   else
      n:=strtran(n,chr(0),"")
   end
   AADD(pila,GETENV(n))
return .T.

function funsay(pila)
local n
   n:=SDP(pila) 
   if valtype(n)=="N"
/*     if ISTNUMBER(n)==1
        AADD(pila,val(n))
     elseif ISNOTATION(n)==1
        n:=e2d(n)
     else */
        n:=hb_ntos((n))
   //  end
   else
      n:=strtran(n,chr(0),"")
   end
   fwrite(1,n)
return .T.

function funnext(pila,par,ITERACION)   // NEXT
local tmpPar               //? "PASA"
   if SWBIG
      nSavePos := FSEEK( fp, 0, 1 )  // rescata posicion anterior
      //CX:=FREADSTR(fp,BUFFERLINEA)
      //par := SUBSTR( CX, 1, at(hb_osnewline(),CX)-1)  // quito newline aqui
      tmpPar:=par
      par:=FREADSPECIAL(fp,BUFFERLINEA)
      NUMTOK:=numtoken(par,DEFTOKEN)

      nEol:=len(par)+1  // debe contar los caracteres especiales para el FSEEK
      TC:=nSavePos+nEol  //TC+nEol
      if TC > TOTALCAR
          //_ERROR("LA MONA DICE: NEXT HA SUPERADO EL FIN DE ARCHIVO")
          //hb_keyPut(27)
          //i:=LENP+1
          //SWSTOP:=.T.
         FSEEK( fp, nSavePos, 0 )  // rescatamos la última posición válida
         par:=tmpPar    // rescatamos la última línea leida
         SWEOF:=.T.
      else
         FSEEK( fp, TC, 0 ) 
         ++ITERACION
      end
   else
      _ERROR("LA MONA DICE: NEXT SOLO SE PUEDE USAR CON LECTURA DE ARCHIVO")
      RETURN .F.                  
   end
return .T.

function funback(pila,par,ITERACION)   // BACK
   if SWBIG
      FSEEK( fp, nSavePos, 0 )  // posicion anterior.
      --ITERACION
   else
      _ERROR("LA MONA DICE: BACK SOLO SE PUEDE USAR CON LECTURA DE ARCHIVO")
      RETURN .F.                  
   end

return .T.

//       "+","-","*","/","\","^","%","|","&",;   // O   93-101
//       "<=",">=","<>","=","<",">"}  // P  102-107
function funequal(pila,o,n,vtip)  // 105
               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o==n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)==n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)==n,0,1))
               end
return .T.
function funle(pila,o,n,vtip)  // 105
               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o<=n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)<=n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)<=n,0,1))
               end
return .T.
function funge(pila,o,n,vtip)  // 106
               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o>=n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)>=n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)>=n,0,1))
               end
return .T.
function funless(pila,o,n,vtip)  // 109
               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o<n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)<n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)<n,0,1))
               end
return .T.
function fungreat(pila,o,n,vtip)  // 110

               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o>n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)>n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)>n,0,1))
               end
return .T.
function funneq(pila,o,n,vtip)  // 107
               if isany(vtip,"NN","CC") // vtip=="NN" .or. vtip=="CC"
                  AADD(pila,iif(o!=n,0,1))
               elseif vtip=="NC"
                  AADD(pila,iif(hb_ntos(o)!=n,0,1))
               elseif vtip=="CN"
                  AADD(pila,iif(val(o)!=n,0,1))
               end
return .T.

function funplus(pila,o,n,vo,vn)  // 93

               if vn=="N"
                  if vo=="N"
                     AADD(pila,o+n)
                  else
                     o:=strtran(o,chr(0),"")
                     AADD(pila, substr(o,n+1,len(o))+chr(0))
                  end
               elseif vo=="N"
                  n:=strtran(n,chr(0),"")
                  AADD(pila, substr(n,o+1,len(n))+chr(0))
               else // sea numeros o strings
                 // ? "N=",n," O=",o
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  AADD(pila,(o+n)+chr(0))  // concatena
               end
return .T.
function funminus(pila,o,n,vo,vn)  // 94
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
                     tmpo:=""
                     if len(n)>0 .and. len(o)>0
                     if len(o)>=len(n)
                     tmpo:=o; tmpn:=n
                     if !SWSENSITIVE   
                        o:=upper(o);n:=upper(n)
                     end
                     id:=numat(n,o)
                     if id>0
                        j:=1
                        while j<=id
                           ids:=atnum(n,o,j)
                           ids:=BUSCACOMPLETA(ids,o,len(n))
                           if ids>0
                              c1:=substr(tmpo,1,ids-1)
                              c2:=substr(tmpo,ids+len(tmpn),len(tmpo))
                              tmpo:=c1+c2
                              if !SWSENSITIVE
                                 o:=upper(tmpo)
                              else
                                 o:=tmpo
                              end
                              id:=numat(n,o)
                              j:=0
                           end
                           ++j
                        end
                     end
                     end
                     end
                  //   ??" O=",o; inkey(0)
                     aadd(pila,tmpo+chr(0))
                  end
               end
return .T.
function funmulti(pila,o,n,vo,vn)  // 95
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
return .T.
function fundiv(pila,o,n,vo,vn)  // 96
               if vn=="N"
                  if vo=="N"
                     if n!=0
                        AADD(pila,o/n)
                     else
                        AADD(pila,"DIV/0")
                     end
                  else
                     o:=strtran(o,chr(0),"")
                     //? "O=",o," N=",n
                     AADD(pila,substr(o,n,len(o))+chr(0))
                  end
               else
                 /// ? "O=",o," N=",n
                  if vo=="C"
                     n:=strtran(n,chr(0),"")
                     o:=strtran(o,chr(0),"")
                     AADD(pila, CHARONLY(n,o)+chr(0)) // solo deja en "n" los caracteres de "o"
                  else
                     n:=strtran(n,chr(0),"")
                     AADD(pila,substr(n,1,o)+chr(0))
                  end
               end
return .T.
function funaor(pila,o,n,vo,vn)  // 100
               vn:=vo+vn
               if vn=="NN"
                  AADD(pila,XNUMOR(o,n))
               elseif vn=="CC"
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  if SWSENSITIVE
                     AADD(pila,iif(o $ n,0,1))
                  else
                     AADD(pila,iif(upper(o) $ upper(n),0,1))
                  end
               else
                  _ERROR("LA MONA DICE: TIPOS DISTINTOS EN OPERACION | (OR|CONTENIDO) ")
                  RETURN .F.
               end
return .T.
function funaand(pila,o,n,vo,vn)  // 101
               vn:=vn+vo
               if vn=="NN"
                  AADD(pila,XNUMAND(o,n))
               elseif vn=="CC"
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  if !SWSENSITIVE
                     n:=upper(n)
                     o:=upper(o)
                  end
                  id:=numat(o,n)
                  ///?"ID=",id
                  if id>0
                     swFound:=.F.
                     ids:=0
                     for j:=1 to id
                        ids:=ATNUM(o,n,j)
                        ids:=BUSCACOMPLETA(ids,n,len(o))
                        if ids>0
                          swFound:=.T.
                          exit
                        end
                     end
                     if swFound
                        AADD(pila,0)
                     else
                        AADD(pila,1)
                     end
                  else
                     AADD(pila,1)
                  end
                 // AADD(pila,CHARAND(o,n)+chr(0))
               else
                  _ERROR("LA MONA DICE: TIPOS DISTINTOS EN OPERACION & (AND|SUB EXACTO) ")
                  RETURN .F.
               end
return .T.

function funshfr(pila,o,n,vo,vn)   // 102
  // 102 desplazamiento según si es numero o caracter
            vn:=valtype(o)+valtype(n)
            if vn=="NN"
               AADD(pila,HB_BITSHIFT(o,n*(-1)))
            elseif vn=="CN"
               AADD(pila,CHARSHR(o,n)+chr(0))
            else
               _ERROR("LA MONA DICE: TIPOS DISTINTOS EN OPERACION BINARIA >> ")
               RETURN .F.
            end
return .T.
function funshfl(pila,o,n,vo,vn)  // 103
 //  desplazamiento según si es numero o caracter
            vn:=valtype(o)+valtype(n)
            if vn=="NN"
               AADD(pila,HB_BITSHIFT(o,n))
            elseif vn=="CN"
               AADD(pila,CHARSHL(o,n)+chr(0))
            else
               _ERROR("LA MONA DICE: TIPOS DISTINTOS EN OPERACION BINARIA << ")
               RETURN .F.
            end
return .T.
function funoxor(pila,o,n,vo,vn)  // 104  xor
            vn:=valtype(n)+valtype(o)
            if vn=="NN"
               AADD(pila,XNUMXOR(o,n))
            elseif vn=="CC"
               AADD(pila,CHARXOR(o,n)+chr(0))
            else
               _ERROR("LA MONA DICE: TIPOS DISTINTOS EN OPERACION BINARIA ! (XOR) ")
               RETURN .F.
            end
return .T.

function funidiv(pila,o,n,vo,vn,par)  // 97
               if vn=="N" 
                  if vo=="N"
                     if n!=0
                        AADD(pila,round(o/n,0))
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
return .T.
function funpot(pila,o,n,vo,vn,par)  // 98

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

                    // tmpo:=o; tmpn:=n
                     if !SWSENSITIVE   
                        o:=upper(o);n:=upper(n)
                     end
                     id:=numat(n,o)
                     if id>0
                        j:=1
                        while j<=id
                           ids:=atnum(n,o,j)
                           ids:=BUSCACOMPLETA(ids,o,len(n))
                           if ids>0
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
return .T.
function funmodulo(pila,o,n,vo,vn)  // 99
local vip
vip:=vn+vo
////? "VIP=",vip," O=",o," N=",n
               if vip=="NN"
                  AADD(pila,o%n)
               elseif vip=="NC"
                  o:=strtran(o,chr(0),"")
                //  ? "POS=",POSCARACTER(o,n)
                  AADD(pila, POSCARACTER(o,n)+chr(0))
               elseif vip=="CC"
                  n:=strtran(n,chr(0),"")
                  o:=strtran(o,chr(0),"")
                  AADD(pila, iif(LIKE(n,o),0,1))
               else
                  AADD(pila,"TYPE-%-ERROR")
               end
return .T.

function funneg(pila, VARIABLE)
LOCAL n,vn
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN OPERACION ~(EXPR) (NOT) ")
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
     _ERROR("LA MONA DICE: TIPO NUMERICO ESPERADO EN ~(EXPR) (NOT) ")
     RETURN .F.
  end
return .T.
/*HB_FUNC( FUNMOV )
{
   PHB_ITEM pPila = hb_param( 1, HB_IT_ARRAY );
   PHB_ITEM pVart = hb_param( 2, HB_IT_ARRAY );
   
   PHB_ITEM pn = Saca(pPila);
   PHB_ITEM po = Saca(pPila);
   long int nInd=0; 
   if(!IS_NIL( pn ) && !IS_NIL( po )){
      if ( !HB_ISNUM ( po ) ){
          const char * cNum = hb_itemGetCPtr( po );
          
          nInd = strtonum( cNum );
      }else nInd = hb_itemGetNL( po );
      
      hb_retl( 1 );
   }else{
      fprintf(stderr, "LA MONA DICE: @N RECIBE UN VALOR NULO\n");
      hb_retl( 0 );
   }
} */

function funmov(pila, VARTABLE)
LOCAL o,n
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o)  //n==NIL .or. o==NIL
     _ERROR("LA MONA DICE: @N RECIBE UN VALOR NULO"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if o>0 .and. o<=SIZEVAR
     VARTABLE[o]:=n
  else
     _ERROR("LA MONA DICE: REGISTRO "+HB_NTOS(o)+" NO EXISTE MOV(<<1.."+hb_ntos(SIZEVAR)+">>,...) L:"+hb_ntos(i) )
     return .F.
  end
return .T.

function funvar(pila, VARTABLE)
local o
  o:=SDP(pila)
  if esnulo(o)   //o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN '@N'"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if o>=1 .and. o<=20
     aadd(PILA,VARTABLE[o])
  else
     _ERROR("LA MONA DICE: REGISTRO "+HB_NTOS(o)+" NO EXISTE @(<<1..N>>) L:"+hb_ntos(i) )
     return .F.
  end
return .T.

function funjnz(pila,p,i,LENP)
LOCAL n,pilaif:={}
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN '?'"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if n!=NIL
     if valtype(n)=="N"
        n:=hb_ntos(n)
     else
        n:=strtran(n,chr(0),"")
     end
     //  ? "ENTRA ?"
     // ? "JNZ=",n; inkey(0)
     IF LEN(n)>0 .and. n!="0"  // busco "ELSE"
        ++i  //pos: codigo de funcion
        while i<=LENP
           //if valtype(p[i])=="N"  //"C"
         //  ? "p(",i,")=",p[i]
           if p[i]==2 // "FNB"
              ++i
              if p[i]==8  //"ELSE" 
                 if len(pilaif)==0
                    exit
                 end
                 ++i
              elseif p[i]==9  //"ENDIF"
                 if len(pilaif)>0
                    asize(pilaif,len(pilaif)-1)
                    ++i
                 else
                    exit
                 end
              elseif p[i]==7 //JNZ  // pone en pila
                 aadd(pilaif,1)
                 ++i
              end
           else
              i += 2  // avanzo a sig. codigo de funcion
           end
           //end
           //++i
        end
        if len(pilaif)>0
           _ERROR("LA MONA DICE RESPECTO A '?': EXPRESION << EXPR ? >> MAL FORMADA ")
           RETURN .F.
        end
     END
  else
     _ERROR("LA MONA DICE RESPECTO A '?': NO EXISTE UNA EXPRESION PARA ? << EXPR ? >>")
     RETURN .F.
  end

return .T.

function funelse(pila,p,i,LENP)
LOCAL pilaif:={}
  ++i
 // ? "ENTRA ELSE"
  while i<=LENP
     //if valtype(p[i])=="C"
     //? "p(",i,")=",p[i]
      if p[i]==2 //"FNB"
          ++i
          if p[i]==8   ///"ELSE"
           if len(pilaif)==0
              exit
           end
           ++i
          elseif p[i]==9   //"ENDIF"
           if len(pilaif)>0
              asize(pilaif,len(pilaif)-1)
              ++i
           else
              exit
           end
          elseif p[i]==7   //"JNZ"  // pone en pila
           aadd(pilaif,1)
           ++i
          end
      else
          i += 2  // avanzo a sig, codigo de funcion
      end
     //end
     //++i
  end
  if len(pilaif)>0
     _ERROR("LA MONA DICE RESPECTO A ':' : EXPRESION << EXPR ? >> MAL FORMADA")
     RETURN .F.
  end
return .T.

function funendif(pila)
  // nada.
 //   ? "ENTRA ENDIF"
return .T.

function funpool(pila,JMP,LENJMP,LENP,i)
  if i<LENP
     aadd(JMP,i)
     LENJMP:=len(JMP)
  end
return .T.
            
function funround(pila,JMP,LENJMP,LENP,i)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ROUND"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,ROUND(n,o))
return .T.
       
function funloop(pila,JMP,LENJMP,LENP,i)
  if LENJMP>0
     n:=SDP(pila)
     if esnulo(n)   //n==NIL
        _ERROR("LA MONA DICE: VALOR NULO EN PUNTERO A DIRECCION LOOP"+_CR+"Quizas no encerraste una expresión entre paréntesis")
        RETURN .F.
     end
     if valtype(n)!="N"
        n:=strtran(n,chr(0),"")
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
     _ERROR("LA MONA DICE: LOOP sin POOL") 
     return .F.
  end
return .T.

function funutf8(pila,JMP,LENJMP,LENP,i)   
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN UTF8"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"") 
  end
  
  AADD(pila,hb_strtoutf8(n)+chr(0))
return .T.

function funansi(pila,JMP,LENJMP,LENP,i)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ANSI"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila,hb_utf8tostr(n)+chr(0))
return .T.

function funcat(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN CAT '{}'"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end

  if len(n)==0
     AADD(pila,o+chr(0))
  elseif len(o)==0
     AADD(pila,n+chr(0))
  else
     AADD(pila,(n+o)+chr(0))
  end
return .T.

function funmatch(pila)
LOCAL o,n,xvar,j,id,c3,ids
  n:=SDP(pila)  // palabras a buscar
  o:=SDP(pila)  // variable: debe ser string
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN MATCH"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  xvar:=0
  // busca tokens:
  if !SWSENSITIVE
     n:=upper(n); o:=upper(o)
  end
  n:=strtran(n,"\;",chr(1))
               
  id:=numtoken(n,chr(1))
  j:=1
  while j<=id
     ids:=token(n,chr(1),j)
     c3:=atnum(ids,o,1)
     c3:=BUSCACOMPLETA(c3,o,len(ids))
     if c3>0
        ++xvar
     end
     ++j
  end
  aadd(pila,xvar-id) //alltrim(str(xvar-id))+chr(0))
return .T.

function funlenstr(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN LEN"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     AADD(pila,len(alltrim(str((n)))))
  else
     n:=strtran(n,chr(0),"")
     AADD(pila,len(n))
  end
return .T.

function funsub(pila)
LOCAL m,n,o
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m)   //n==NIL.or.o==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN SUB"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)!="N"
     m:=strtran(m,chr(0),"")
     m:=val(m)
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  
  if n==0 .or. m==0
     AADD(pila,""+chr(0))   // opcion: no pone nada.
  else
     AADD(pila,substr(o,n,m)+chr(0))
  end
return .T.

function funat(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN AT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  if !SWSENSITIVE
     o:=upper(o); n:=upper(n)
  end

  AADD(pila, at(o,n) )
return .T.

function funrange(pila)
LOCAL o,n,h
  o:=SDP(pila)
  n:=SDP(pila)
  h:=SDP(pila)
  if esnulo(n,o,h)   //n==NIL.or.o==NIL.or.h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN RANGE"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  end
  h:=strtran(h,chr(0),"")
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila,POSRANGE(chr(n),chr(o),h))
return .T.

function funat1(pila)
LOCAL x,o,n,y
  x:=SDP(pila)  // ocurrencia
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o,x)   //n==NIL.or.o==NIL.or.x==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ATA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(x)!="N"
     x:=strtran(x,chr(0),"")
     x:=val(x)
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  if !SWSENSITIVE
     o:=upper(o); n:=upper(n)
  end
  y:=numat(o,n)
  AADD(pila, atnum(o,n,x) )
return .T.

function funaf(pila)
LOCAL n,o,j,id,ids,sw:=.F.
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN AF"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  
               
  if !SWSENSITIVE   
     o:=upper(o);n:=upper(n)
  end
  id:=numat(n,o)
  if id>0
     j:=1
     while j<=id
        ids:=atnum(n,o,j)
        ids:=BUSCACOMPLETA(ids,o,len(n))
        if ids>0
           AADD(pila, ids )
           sw:=.T.
           exit
        end
        ++j
     end
     if !sw
        //if j>id
        aadd(pila,0)
        //end
     end
  else
     aadd(pila,0)
  end
return .T.

function funrat(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN RAT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  
  if !SWSENSITIVE
     o:=upper(o); n:=upper(n)
  end
  AADD(pila, rat(o,n) )
return .T.

function funptrp()
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN PTRP {+S}"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila, substr(n,o,len(n))+chr(0))
return .T.

function funptrm(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN PTRM {-S}"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  
  AADD(pila, substr(n,1,len(n)-o)+chr(0))  
return .T.

function funcp(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN CP"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila,replicate(n,o)+chr(0))
return .T.

function funtr(pila)
LOCAL m,n,o
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m)   //n==NIL.or.o==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TR"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
    m:=strtran(m,chr(0),"")   
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
    n:=strtran(n,chr(0),"")   
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
    o:=strtran(o,chr(0),"")   
  end
  AADD(pila,strtran(o,n,m)+chr(0))
return .T.

function funtr1(pila)
LOCAL x,h,m,n,o
  x:=SDP(pila)  // omite y reemplaza
  h:=SDP(pila)  // omite
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m,h,x)   //n==NIL.or.o==NIL.or.x==NIL.or.h==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TRA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)!="N"
        h:=strtran(h,chr(0),"")
        h:=val(h)
  end
  if valtype(x)!="N"
     x:=strtran(x,chr(0),"")
     x:=val(x)
  end
  if valtype(h)!="N"
     h:=strtran(h,chr(0),"")
     h:=val(h)
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
     m:=strtran(m,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  AADD(pila,strtran(o,n,m,h,x)+chr(0))
return .T.

function funtr2(pila)
LOCAL h,m,n,o
  h:=SDP(pila)  // omite
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m,h)   //n==NIL.or.o==NIL.or.m==NIL.or.h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TRB"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)!="N"
        h:=strtran(h,chr(0),"")
        h:=val(h)
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
     m:=strtran(m,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")   
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  AADD(pila,strtran(o,n,m,h)+chr(0))
return .T.

function funaf1(pila)
LOCAL x,n,o,id,ids,j,y,sw:=.F.
  x:=SDP(pila)  // ocurrencia
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,x)   //n==NIL.or.o==NIL.or.x==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN AFA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(x)!="N"
     x:=strtran(x,chr(0),"")
     x:=val(x)
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  if !SWSENSITIVE   
     o:=upper(o);n:=upper(n)
  end
  id:=numat(n,o)
  if id>0
     j:=1
     y:=0
     while j<=id
        ids:=atnum(n,o,j)
        ids:=BUSCACOMPLETA(ids,o,len(n))
        if ids>0
           if j==x
//              ? "MATCH! pos=",j," x=",x," ID=",id
              AADD(pila, ids )
              sw:=.T.
              exit
         //  else
         //     y:=ids
           end
        else  // no es completa, pero es un match: aumento x
           ++x
        end
        ++j
     end
     if !sw
        //if j>id
        //   if y>0
        //      AADD(pila, y )
        //   else
              aadd(pila,0)
        //   end
        //end
     end
  else
     aadd(pila,0)
  end
return .T.

function funtk(pila,tBUFFER)
LOCAL m,o,n
  m:=SDP(pila)
  o:=SDP(pila)
  if esnulo(m,o)   //m==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TK $N"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)!="N"
     m:=strtran(m,chr(0),"")
     m:=val(m)
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  
 // if m==0
 //    AADD(pila,par+chr(0))
  if m<=0
     _ERROR("LA MONA DICE: NO ACEPTO UN INDICE DE TOKEN NEGATIVO O CERO")
     return .F.
  else
/*     if m>NUMTOK
        AADD(pila,""+chr(0))
     else*/
     n:=alltrim(token(o,DEFTOKEN,m))
    // ? "TK=",n," len=",len(n)
     if len(n)>0
     if ISTNUMBER(n)==1
        AADD(pila,val(n))
     elseif ISNOTATION(n)==1
        AADD(pila,e2d(n))
     else
        AADD(pila,n+chr(0))
     end
     else
        AADD(pila,""+chr(0))
     end
  end
return .T.

function funlet(pila,tBUFFER)
LOCAL h,o
  h:=SDP(pila)  // string.
  o:=SDP(pila)  // linea.debe ser un número
  if esnulo(h,o)   //h==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN LET"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  else
     h:=strtran(h,chr(0),"")
  end
  if valtype(o)!="N"
//    ? "O=",o
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  
  if o>0 .and. o<=len(tBUFFER)
     tBUFFER[o]:=h
  else
     _ERROR("LA MONA DICE: LINEA REFERENCIADA EN LET NO EXISTE")
     return .F.
  end
return .T.

function funletk(pila,tBUFFER)
LOCAL h,o,n,c1,c2,j,str,xvar
  h:=SDP(pila)  // token 2. puede ser un string.
  n:=SDP(pila)  // token 1. debe ser un numero, indice de token
  o:=SDP(pila)  // linea
  if esnulo(n,o,h)   //n==NIL.or.o==NIL.or.h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TKLET"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if o==NIL
     _ERROR("LA MONA DICE: LINEA REFERENCIADA EN TKLET NO EXISTE")
     return .F.
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
return .T.

function funcopy(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN COPY"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
/*  if n==NIL
     _ERROR("LA MONA DICE: NO ENCUENTRO UN DATO VALIDO PARA COPIAR EN BUFFER <<COPY(null)>>")
     RETURN .F.
  else*/
  if len(n)>0 .and. n!="0"
     AADD(tBUFFER,alltrim(n))
  end
return .T.

function fungloss(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN GLOSS"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     IF ABS(n)>INFINITY().or. (ABS(n)>0.and.ABS(n)<0.000000000001)
        n:=D2E(n,10)
     else
        n:=hb_ntos(n)
     end
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila,GLOSA(n)+chr(0))
return .T.

function funtri(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TRI"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  AADD(pila,alltrim(n)+chr(0))
return .T.

function funltri(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN LTRI"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  AADD(pila,ltrim(n)+chr(0))
return .T.

function funrtri(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN RTRI"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  AADD(pila,rtrim(n)+chr(0))
return .T.

function funup(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN UP"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila,upper(n)+chr(0))
return .T.

function funlow(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN LOW"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila,lower(n)+chr(0))
return .T.

/*function funrp(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)  // debe sacarlo, porque sino, no reemplaza
//  if esnulo(n,o)   //n==NIL.or.o==NIL
//     _ERROR("LA MONA DICE: VALOR NULO EN RP")
//     RETURN .F.
//  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  end
  o:=strtran(o,chr(0),"")
  AADD(pila,o)
return .T.*/

function funtre(pila)
LOCAL m,n,o,ids,id,j,c1,c2
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m)   //n==NIL.or.o==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TRE"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
     m:=strtran(m,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  id:=numat(n,o)
  if id>0
     j:=1
     while j<=id
        ids:=atnum(n,o,j)
        ids:=BUSCACOMPLETA(ids,o,len(n))
        if ids>0
           c1:=left(o,ids-1)  //substr(o,1,ids-1)
           c2:=substr(o,ids+len(n),len(o))
           o:=c1+m+c2
           --j
        end
        ++j
     end
  end
  aadd(pila,o+chr(0))
return .T.

function funtre2(pila)
LOCAL h,m,n,o,id,ids,j,c1,c2
  h:=SDP(pila)
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m,h)   //n==NIL.or.o==NIL.or.m==NIL.or.h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TREB"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)!="N"
     h:=strtran(h,chr(0),"")
     h:=val(h)
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
     m:=strtran(m,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  id:=numat(n,o)
  if id>0   // encontré ocurrencias 
     if id>=h   // hay mas de las que debo omitir,
        j:=1
        while j<=h-1
           ids:=atnum(n,o,j)
           ids:=BUSCACOMPLETA(ids,o,len(n))
           if ids==0
              ++h
           end
           ++j
        end
        j:=h
        while j<=id
        ids:=atnum(n,o,j)
        ids:=BUSCACOMPLETA(ids,o,len(n))
        if ids>0
           c1:=left(o,ids-1)   //substr(o,1,ids-1)
           c2:=substr(o,ids+len(n),len(o))
           o:=c1+m+c2
           --j
        end
        ++j
        end
     end
  end
  aadd(pila,o+chr(0))
return .T.

function funtre1(pila)
LOCAL x,k,h,m,n,o,id,ids,j,c1,c2
  x:=SDP(pila)
  h:=SDP(pila)
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m,h,x)   //n==NIL.or.o==NIL.or.m==NIL.or.h==NIL.or.x==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN TREA"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(x)!="N"
     x:=strtran(x,chr(0),"")
     x:=val(x)
  end
  if valtype(h)!="N"
     h:=strtran(h,chr(0),"")
     h:=val(h)
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
     m:=strtran(m,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  id:=numat(n,o)
  if id>0   // encontré ocurrencias 
     if id>=h   // hay mas de las que debo omitir,
        j:=1
        while j<=h-1
           ids:=atnum(n,o,j)
           ids:=BUSCACOMPLETA(ids,o,len(n))
           if ids==0
              ++h
           end
           ++j
        end
        j:=h
        if id>x+h
           id:=x+h
        end
        k:=0
        while j<=id
           ids:=atnum(n,o,j)
           ids:=BUSCACOMPLETA(ids,o,len(n))
           if ids>0
              c1:=left(o,ids-1)   //substr(o,1,ids-1)
              c2:=substr(o,ids+len(n),len(o))
              o:=c1+m+c2
              --j
              ++k
              if k==x
                 exit
              end
           end
           ++j
        end
     end
  end
  aadd(pila,o+chr(0))
return .T.

function funins(pila)
LOCAL m,n,o,xvar
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m)   //n==NIL.or.o==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN INS"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)!="N"
     m:=strtran(m,chr(0),"")
     m:=val(m)
  end 
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  
  if m>0
     xvar:=substr(o,m+1,len(o))
     
     AADD(pila,substr(o,1,m)+n+xvar+chr(0))
  else
     AADD(pila,o+chr(0))
  end
return .T.

function funrpc(pila)
LOCAL m,n,o
  m:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,m)   //n==NIL.or.o==NIL.or.m==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN RPC"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(m)=="N"
     m:=hb_ntos(m)
  else
    m:=strtran(m,chr(0),"")   
  end 
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
    n:=strtran(n,chr(0),"")   
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
    o:=strtran(o,chr(0),"")   
  end

  AADD(pila,CHARREPL(n,o,m)+chr(0))
return .T.

function funone(pila)
LOCAL n,o
  n:=SDP(pila)  // caracter a reducir
  o:=SDP(pila)  // variable: debe ser string
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ONE"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
    n:=strtran(n,chr(0),"")   
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
    o:=strtran(o,chr(0),"")   
  end
  AADD(pila,CHARONE(n,o)+chr(0))
return .T.

function fundc(pila)
LOCAL n,o
  n:=SDP(pila)  // caracteres a eliminar
  o:=SDP(pila)  // variable: debe ser string
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN DC"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
    n:=strtran(n,chr(0),"")   
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
    o:=strtran(o,chr(0),"")   
  end
  AADD(pila,CHARREM(n,o)+chr(0))
return .T.

function funrnd(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN RND"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,HB_RANDOM()*n)
return .T.

function funval(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN VAL"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
    // if len(n)>0
     if ISTNUMBER(n)==1
        AADD(pila,val(n))
     elseif ISNOTATION(n)==1
        AADD(pila,e2d(n))
     else
        _ERROR("LA MONA DICE: CONVERSION NO VALIDA EN VAL <<VAL( STRING-NO-NUMERIC )>>")
        RETURN .F.
     end
    // else
    //    AADD(pila,0)
    // end
  else
     AADD(pila,n)
  end
return .T.

function funstr(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN STR"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     AADD(pila,hb_ntos(n)+chr(0))
  else
     n:=strtran(n,chr(0),"")
     AADD(pila,n+chr(0))
  end
return .T.

function funch(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN CH"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,chr(n)+chr(0))
return .T.

function funasc(pila,tBUFFER)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ASC"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  IF LEN(n)>1
     n:=substr(n,1,1)
  end
  AADD(pila,asc(n))
return .T.

function funlin(pila,tBUFFER)
LOCAL n,v
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN LIN"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if n>0 .and. n<=LEN(tBUFFER)
     //AADD(pila,STRING[n]) //strtran(BUFFER[n],chr(127),""))
     if valtype(BUFFER[n])=="C"
        v:=strtran(BUFFER[n],chr(0),"")
     
     if ISTNUMBER(v)==1
        AADD(pila,val(v))
     elseif ISNOTATION(v)==1
        AADD(pila,e2d(v))
     else
        AADD(pila,v)
     end
     else
        AADD(pila,BUFFER[n])
     end
  else
     _ERROR("LA MONA DICE: NO EXISTE LA LINEA PEDIDA EN EL BUFFER (LIN)")
     RETURN .F.
  end
return .T.

function funpc(pila,tBUFFER)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN PC"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  
  AADD(pila, padc(n,o)+chr(0))
return .T.

function funpl(pila,tBUFFER) 
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN PL"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  
  AADD(pila, padl(n,o)+chr(0))
return .T.

function funpr(pila,tBUFFER) 
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN PR"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end

  AADD(pila, padr(n,o)+chr(0))
return .T.

function funmsk(pila)
LOCAL n,o,c1,c2
  n:=SDP(pila)  // relleno y mascara
  o:=SDP(pila)  // variable: debe ser numerico
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN MSK"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  c1:=substr(n,1,1)    // relleno
  c2:=substr(n,2,len(n)) // mascara
  AADD(pila,XFUNMASK(o,c2,c1)+chr(0))
return .T.

function funmon(pila)
LOCAL h,n,m,o,c1,c2
  h:=SDP(pila)  // decimales
  m:=SDP(pila)  // ancho
  n:=SDP(pila)  // relleno y signo moneda
  o:=SDP(pila)  // variable: debe ser numerico
  if esnulo(n,o,m,h)   //n==NIL.or.o==NIL.or.m==NIL.or.h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN MON"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)!="N"
     h:=strtran(h,chr(0),"")
     h:=val(h)
  end
  if valtype(m)!="N"
     m:=strtran(m,chr(0),"")
     m:=val(m)
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  c1:=substr(n,1,1)    // relleno
  c2:=substr(n,2,len(n)) // tipo moneda
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila,XFUNMONEY(o,c2,c1,h,m)+chr(0))
return .T.

function funsat(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN SAT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")
     o:=strtran(o,"\n",HB_OSNEWLINE())
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  
  AADD(pila, XFUNCCCSATURA(n, DEFTOKEN, o)+chr(0))
return .T.

function fundeft(pila)
LOCAL h
  h:=SDP(pila)  // string.
  if esnulo(h)   //h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN DEFT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  else
     h:=strtran(h,chr(0),"")
  end
  
  DEFTOKEN:=h
  ////NUMTOK:=numtoken(par,DEFTOKEN) // defino variable global
return .T.

function funif(pila)
LOCAL h,n,o
  h:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,h)   //n==NIL.or.o==NIL.or. h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN IF"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  else
    h:=strtran(h,chr(0),"")   
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")  
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")  
  end

  if len(alltrim(o))==0 .or. val(o)==0
     AADD(pila,n)
  else
     AADD(pila,h)
  end
return .T.

function funifle(pila)
LOCAL h,n,o
  h:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,h)   //n==NIL.or.o==NIL.or. h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN IFLE"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  else
    h:=strtran(h,chr(0),"")   
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")  
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")  
  end
  if val(o)<=0 .and. ISTNUMBER(o)==1
     AADD(pila,n)
  else
     AADD(pila,h)
  end
return .T.

function funifge(pila)
LOCAL h,n,o
  h:=SDP(pila)
  n:=SDP(pila)
  o:=SDP(pila)
  if esnulo(n,o,h)   //n==NIL.or.o==NIL.or. h==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN IFGE"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(h)=="N"
     h:=hb_ntos(h)
  else
    h:=strtran(h,chr(0),"")   
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")  
  end
  if valtype(o)=="N"
     o:=hb_ntos(o)
  else
     o:=strtran(o,chr(0),"")  
  end
  if val(o)>=0 .and. ISTNUMBER(o)==1
     AADD(pila,n)
  else
     AADD(pila,h)
  end
return .T.

function funand(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN AND"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,iif(o==0 .and. n==0,0,1))
return .T.

function funor(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN OR"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,iif(o==0 .or. n==0,0,1))
return .T.

function funxor(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN XOR"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,iif((o==0.and.n!=0).or.(o!=0.and.n==0),0,1))
return .T.

function funnot(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN NOT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,XNUMNOT(n))
return .T.

function funbit(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN BIT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila,XGETBIT(n,o,1))
return .T.

function funon(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN ON"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila,XSETBIT(n,o+1))
return .T.

function funoff(pila)
LOCAL o,n
  o:=SDP(pila)
  n:=SDP(pila)
  if esnulo(n,o)   //n==NIL.or.o==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN OFF"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  if valtype(o)!="N"
     o:=strtran(o,chr(0),"")
     o:=val(o)
  end
  AADD(pila,XCLEARBIT(n,o+1))
return .T.

function funbin(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN BIN"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,DECTOBIN(n)+chr(0))
return .T.

function funhex(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN HEX"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
 // ? "::","0x"+DECTOHEXA(n)+"h"
  AADD(pila,DECTOHEXA(n)+chr(0))
return .T.

function fundec(pila)
LOCAL n,c1,c2,c,num,j,xt
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN DEC"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)=="N"
     n:=hb_ntos(n)
  else
     n:=strtran(n,chr(0),"")
  end
  num:=""
  c1:=substr(n,1,2)
  c2:=substr(n,len(n),1)
  if c1!="0x" .or. !(c2 $ "bho")
     _ERROR("LA MONA DICE: BASE NUMERICA NO RECONOCIDA: "+n)
       RETURN .F.
  end
  n:=substr(n,3,len(n))
  IF LEN(n)>1
     num:=""
     j:=1
     while j<=LEN(n)
       c:=substr(n,j,1)
       if isdigit(c) .or. isany(c,"A","B","C","D","E","F") // c=="A".or.c=="B".or.c=="C".or.c=="D".or.c=="E".or.c=="F"
          num+=c
       else
          exit
       end
       ++j
     end
     if c=="b"     // es binairo
       for j:=1 to len(num)
         xt:=substr(num,j,1)
         if xt!="0" .and. xt!="1"
           _ERROR("LA MONA DICE: NUMERO BINARIO MAL FORMADO: "+num)
           RETURN .F.
         end
       end
       num:=BINTODEC(num)
     elseif c=="o"   // es octal
       for j:=1 to len(num)
         xt:=substr(num,j,1)
         if !(xt $ "01234567")
           _ERROR("LA MONA DICE: NUMERO OCTAL MAL FORMADO: "+num)
           RETURN .F.
         end
       end
       num:=OCTALTODEC(num)
     elseif c=="h"    // es hexadecimal
       
       for j:=1 to len(num)
         xt:=substr(num,j,1)
         if !(xt $ "0123456789ABCDEF")
            _ERROR("LA MONA DICE: NUMERO HEXADECIMAL MAL FORMADO: "+num)
            RETURN .F.
         end
       end
       num:=HEXATODEC(num)
     else   // no es ninguna hueá: error!
       _ERROR("LA MONA DICE: BASE NUMERICA NO RECONOCIDA: "+num)
       RETURN .F.
     end
  else
     _ERROR("LA MONA DICE: NO HAY NUMERO A CONVERTIR: "+num)
       RETURN .F.
  end
  AADD(pila,num)
return .T.

function funoct(pila)
LOCAL n
  n:=SDP(pila)
  if esnulo(n)   //n==NIL
     _ERROR("LA MONA DICE: VALOR NULO EN OCT"+_CR+"Quizas no encerraste una expresión entre paréntesis")
     RETURN .F.
  end
  if valtype(n)!="N"
     n:=strtran(n,chr(0),"")
     n:=val(n)
  end
  AADD(pila,DECTOOCTAL(n)+chr(0))
return .T.

function funln(pila,n)
  AADD(pila,log(n))
return .T.

function funlog(pila,n)
  AADD(pila,log10(n))
return .T.

function funsqrt(pila,n)
  AADD(pila,sqrt(n))
return .T.

function funabs(pila,n)
  AADD(pila,abs(n))
return .T.

function funint(pila,n)
  AADD(pila,int(n))
return .T.

function funceil(pila,n)
  AADD(pila,ceiling(n))
return .T.

function funexp(pila,n)
  AADD(pila,exp(n))
return .T.

function funfloor(pila,n)
  AADD(pila,floor(n))
return .T.

function funsgn(pila,n)
  AADD(pila,sign(n))
return .T.

function funsin(pila,n)
  if SWRADIANES
     AADD(pila,sin(n))
  else
     AADD(pila,sin(n*PI()/180))
  end
return .T.

function funcos(pila,n)
  if SWRADIANES
     AADD(pila,cos(n))
  else
     AADD(pila,cos(n*PI()/180))
  end
return .T.

function funtan(pila,n)
  if SWRADIANES
     AADD(pila,tan(n))
  else
     AADD(pila,tan(n*PI()/180))
  end
return .T.

function funinv(pila,n)
  AADD(pila,1/n)
return .T.

/***************/

PROCEDURE _ERROR(msg)
   fwrite(1,_CR+msg+_CR+_CR)
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

   RETURN "0x"+cNewString+"b"

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
   RETURN "0x"+cNewString+"o"

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
   RETURN "0x"+cNewString+"h"

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
/*DICC:={"LN","LOG","SQRT","ABS","INT","CEIL","FLOOR","SGN","ROUND","SIN","COS","TAN","UP","LOW","MSK","MON","SAT",;
       "EXP","INV","RP","CAT","LEN","SUB","AT","AF","RAT","PTRP","PTRM","CP","TR","TK","VAL","CH","LIN","PC","PL","PR","IF",;
       "TRE","INS","DC","RPC","ONE","ASC","TRI","LTRI","RTRI","I","INC","DEC","IFLE","IFGE","LETK","MATCH","LET","DEFT",;
       "NT","POOL","LOOP","MOV","VAR","NOP","COPY","AND","OR","XOR","NOT","BIT","ON","OFF","BIN","HEX","OCT","~",;
       "JNZ","ELSE","ENDIF","CLEAR","RANGE","FILE","STR","UTF8","ANSI","GLOSS","RND","L",;
       "FNA","FNB","FNC","FND","FNE","FNF",;
       "FNH","FNI","FNJ","FNK","FNL","FNM","FNN"}
*/
DICC:={"NT","I","VAR","MOV","~","L",;   // A 1-6
       "JNZ","ELSE","ENDIF",;   // B 7-9
       "DO","UNTIL","ROUND","UTF8","ANSI",;           // C 10-14
       "CAT","MATCH","LEN","SUB","AT","RANGE","ATA",;  // D 15-21
       "AF","RAT","PTRP","PTRM","CP","TR","TRA","TRB","AFA",;  // E 22-30
       "TK","TKLET","LET","COPY","FILE","GLOSS",;    // F    31-36
       "RP","TRI","LTRI","RTRI","UP","LOW",;    // G  37-42
       "TRE","INS","DC","RPC","ONE","RND","TREA","TREB",;       // H  43-50
       "VAL","STR","CH","ASC","LIN","PC","PL","PR",;    // I   51-58
       "MSK","MON","SAT","DEFT","IF","IFLE","IFGE","CLEAR",; // J   59-66
       "STOP","AND","OR","XOR",;    // K  67-70
       "NOT","BIT","ON","OFF","BIN","HEX","DEC","OCT",; // L  71-78
       "LN","LOG","SQRT","ABS","INT","CEIL","EXP","NL",;  // M  79-85
       "FLOOR","SGN","SIN","COS","TAN","INV","NEXT",;
       "BACK","TPC","HT","VT","EOF","ENV","SAY"}   //N  86-91 (inv)
                             
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

function es_Lsimbolo(c)
local _ret:=.F.

   if c=="<=" .or. c==">=".or.c=="<>".or.c=="=".or.c=="<".or.c==">"
      _ret:=.T.
   end

return _ret

/*function SDP( _lista )
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
*/
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
   // FERASE ("XUANS_"+EX+".log")
    
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

/*
  DESPLIEGUE CON PRECISION. FUNCION INTERNA DE WRITE Y SHOW
*/
/*char * xu_num2string(double dNum, int Dec){
  char *buf;
  int size;
  buf=(char *)calloc(64,1);
  size = sprintf(buf,"%.*lf",Dec, dNum);
  return(buf);
}

HB_FUNC( XFUNNUM2STRING )
{
  double numero = hb_parnd( 1 );
  int    decimal= hb_parni( 2 );
  char * Retorno = (char*)calloc(64,1);
  char * nDev=xu_num2string(numero,decimal);
  strcpy(Retorno, nDev );
  hb_retc( Retorno );
  free(Retorno);
  free(nDev);
}
*/

HB_FUNC( POSCARACTER )
{
   PHB_ITEM pTEXTO = hb_param(1, HB_IT_STRING );
   HB_SIZE nPos = hb_parni ( 2 );
   char * cRet = (char *)calloc(2,1);
   const char * szText = hb_itemGetCPtr( pTEXTO );
   cRet[0] = szText[nPos-1];
   cRet[1] = '\0';
   hb_retc( cRet );
   free(cRet);
}

HB_SIZE hb_striAt( const char * szSub, HB_SIZE nSubLen, const char * szText, HB_SIZE nLen )
{

   if( nSubLen > 0 && nLen >= nSubLen )
   {
      HB_SIZE nPos = 0;
      nLen -= nSubLen;
      do
      {
         if( HB_TOUPPER(szText[ nPos ]) == HB_TOUPPER(*szSub) )
         {
            HB_SIZE nSubPos = nSubLen;
            do
            {
               if( --nSubPos == 0 )
                  return nPos + 1;
            }
            while( HB_TOUPPER(szText[ nPos + nSubPos ]) == HB_TOUPPER(szSub[ nSubPos ]) );
         }
      }
      while( nPos++ < nLen );
   }

   return 0;
}

HB_FUNC( FREADSPECIAL )
{

   HB_FHANDLE fhnd = ( HB_FHANDLE ) hb_parni( 1 );
   HB_SIZE nToRead = hb_parns( 2 );
   
   HB_ERRCODE uiError = 0;
   char * buffer = ( char * ) hb_xgrab( nToRead + 1 );
   HB_SIZE nRead;
   int cbuf = 0;
   
   nRead = hb_fsReadLarge( fhnd, buffer, nToRead );
   uiError = hb_fsError();
        
   while(buffer[cbuf]!='\n') ++cbuf;
      
   ////buffer[ nRead ] = '\0';
   buffer[ cbuf ] = '\0';
   
   hb_retc_buffer( buffer );
  // free(buffer);
   hb_fsSetFError( uiError );
}

/**** STRTRAN Y FUNCIONES AUXILIARES ****/
/*uint16_t fun_tokens(const char *linea, const char *buscar, uint16_t lb) {
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

char *FUNSTRTRAN(const char *linea,
               const char *buscar,
               const char *reempl,
               int ignore,
               int limite ){
   int ntoken;
   size_t llinea=strlen(linea);
   size_t lbuscar=strlen(buscar);
   size_t lreempl=strlen(reempl);
   if ((ntoken = fun_tokens(linea,buscar,lbuscar))==0){
      char * Retorno = (char *)calloc(llinea+1,1);
      strcpy(Retorno, linea);
      return Retorno;  // para qué voy a calcular.
   }
   if (limite==0) limite = ntoken;

   const char *t;
   char *r;
   size_t l=0;
   size_t size;

   // cálculo del espacio con excedente a reservar
   size = llinea + (lreempl + lbuscar)*ntoken;
   const char *u;
   u = (const char *)linea;
   
   r=(char *)calloc(size+1,1);

   if (r==NULL) return NULL;

   int i=0;
   
   do{
      t = strstr(u,buscar);
      l = t - u;
      if (l>0){
         while(l--){
            r[i] = *u ; 
            ++i; u++;
         }
         r[i]='\0';
      }
      if (ignore > 0) {
/////         printf("\ni = %d\n",i);
         int LB = lbuscar;
         //const char * pLB = buscar;
         while(LB--){
            r[i] = *u; // *pLB;
            ++i; ++u; // ++pLB;
         }
         r[i]='\0';
         ignore--;
      } else {
         if (limite > 0){ // porque si limite==0, limite=ntoken
            int LR = lreempl;
            const char * pLR = reempl;
            while(LR--){
               r[i] = *pLR;
               ++i; ++pLR;
            }
            r[i]='\0';
            limite--;
         } else {
            int LB = lbuscar;
            const char * pLB = buscar;
            while(LB--){
               r[i] = *pLB;
               ++i; ++pLB;
            }
            r[i]='\0';
         }
      }
      t += lbuscar;
      u = t;
   }while(--ntoken);

   while(*u){
     r[i] = *u ; 
     ++i; ++u;
   }
   r[i]='\0';
   
   char * Retorno = (char *)calloc(i+1,1);
   strcpy(Retorno,r);
   free(r);

   return Retorno;
}
//         swrite(RX,SWNUEVALINEA,SWKEEPVACIO)
HB_FUNC( SWRITE ) 
{
  PHB_ITEM pText = hb_param( 1, HB_IT_STRING);
  HB_BOOL SWKEEPVACIO = hb_parl ( 2 ); 
  const char * string = hb_itemGetCPtr( pText );

  long nLen = strlen(string);

  if (*string != '\n'){
     if (strcmp(string,"0") != 0){
        int nWritten = hb_fsWriteLarge( hb_numToHandle( 1 ), string, nLen ) ;
     }else{
        if (SWKEEPVACIO){
           int nWritten = hb_fsWriteLarge( hb_numToHandle( 1 ), string, nLen ) ;
        }
     }
  }else{
     if (SWKEEPVACIO){
        int nWritten = hb_fsWriteLarge( hb_numToHandle( 1 ), string, nLen ) ;
     }
  }

  hb_itemClear( pText );
  
}
*/
// search(cBUSCASTR,BX,swBuscaLinea,SWSENSITIVE,swBuscaExacta,swNoIncluye)
/*HB_FUNC( SEARCH )
{
   PHB_ITEM pBUSCA = hb_param(1, HB_IT_ARRAY );
   PHB_ITEM pTEXTO = hb_param(2, HB_IT_STRING );
   HB_BOOL SWSENSITIVE = hb_parl ( 3 );
   HB_BOOL swNoIncluye = hb_parl ( 4 );
   
  // if (swBuscaLinea){
   HB_ISIZ ulLen = hb_arrayLen( pBUSCA );
   int ndx;
   const char * szText = hb_itemGetCPtr( pTEXTO );
   
   if(swNoIncluye){
      int swExiste=0;
      for( ndx=1;ndx<=ulLen; ndx++ ){
            PHB_ITEM pString = hb_itemArrayGet( pBUSCA, ndx);
            const char * szSub = hb_itemGetCPtr( pString );
            hb_itemRelease(pString);

            if (SWSENSITIVE){
               if (hb_strAt( szSub,strlen(szSub),szText,strlen(szText)) > 0){
                  swExiste=1;
               }
            }else{
               if (hb_striAt( szSub, strlen(szSub), szText, strlen(szText) ) > 0){
                  swExiste=1;
               }
            }
            if (swExiste){
               hb_retl( (HB_BOOL) 1 );  // falso
               break;
            }
      }
      if (!swExiste) hb_retl( (HB_BOOL) 0 );
      
   }else{  // incluye
      int swExiste=0;
      for( ndx=1;ndx<=ulLen; ndx++ ){
            PHB_ITEM pString = hb_itemArrayGet( pBUSCA, ndx);
            const char * szSub = hb_itemGetCPtr( pString );
            hb_itemRelease(pString);
   //         printf("BUSCANDO.... %s\n",szSub);
         
            if (SWSENSITIVE){
               if (hb_strAt( szSub,strlen(szSub),szText,strlen(szText)) > 0){
                  swExiste=1;
               }
            }else{
               if (hb_striAt( szSub, strlen(szSub), szText, strlen(szText) ) > 0){
                  swExiste=1;
               }
            }
            if (swExiste) {
               hb_retl( (HB_BOOL) 0 );  // verdad
               break;
            }
      }
      if (!swExiste) hb_retl( (HB_BOOL) 1 );
   }

   hb_itemClear( pBUSCA );
   hb_itemClear( pTEXTO );
}
*/
// search(busca,texto,swBuscaLinea,SWSENSITIVE)

HB_FUNC( SEARCH )
{
   PHB_ITEM pBUSCA = hb_param(1, HB_IT_STRING );
   PHB_ITEM pTEXTO = hb_param(2, HB_IT_STRING );
 //  HB_BOOL swBuscaLinea = hb_parl ( 3 );
   HB_BOOL SWSENSITIVE = hb_parl ( 3 );
   
   const char * szSub = hb_itemGetCPtr( pBUSCA );
   const char * szText = hb_itemGetCPtr( pTEXTO );
 //  if (swBuscaLinea){
      if (SWSENSITIVE){
          if (hb_strAt( szSub,strlen(szSub),szText,strlen(szText)) > 0){
             hb_retl( (HB_BOOL) 1 );
          }else{
             hb_retl( (HB_BOOL) 0 );
          }
      }else{
          if (hb_striAt( szSub, strlen(szSub), szText, strlen(szText) ) > 0){
             hb_retl( (HB_BOOL) 1 );  // verdad
          }else{
             hb_retl( (HB_BOOL) 0 );  // falso
          }
      }
 //  }else hb_retl( (HB_BOOL) 0 );  // falso
   
   hb_itemClear( pBUSCA );
   hb_itemClear( pTEXTO );
}



//isany(vtip,"NN","CC")
HB_FUNC( ISANY )
{
   int iPCount = hb_pcount();

   HB_BOOL bGood = HB_FALSE;
   if( iPCount > 0 )
   {
      PHB_ITEM pVAR = hb_param( 1, HB_IT_STRING );
      const char * cVAR = hb_itemGetCPtr( pVAR );
      int iParam;
      for( iParam = 2; iParam <= iPCount; iParam++ )
      {
         PHB_ITEM pCom = hb_param( iParam, HB_IT_STRING );
         const char * cCom = hb_itemGetCPtr( pCom );
         if( strcmp( cVAR, cCom ) == 0 )
         {
            bGood = HB_TRUE;
            break;
         }
         hb_itemClear( pCom );
      }
      hb_itemClear( pVAR );
   }
   hb_retl( bGood );
}

HB_FUNC( ESNULO )
{
   int iPCount = hb_pcount();

   HB_BOOL bError = HB_FALSE;
   if( iPCount > 0 )
   {
      
      int iParam;
      for( iParam = 1; iParam <= iPCount; iParam++ )
      {
         if( HB_ISNIL( iParam ) )
         {
            bError = HB_TRUE;
            break;
         }
      }
   }
   hb_retl( bError );
}

/* StackPop( <aStack> ) --> <xValue>
   Returns NIL if the stack is empty
 *
 * renamed: SDP
 * Harbour Project source code:
 * Stack structure
 *
 * Copyright 2000 Jose Lalin <dezac@corevia.com>
 * www - http://harbour-project.org
*/
HB_FUNC( SDP )
{
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   HB_ISIZ ulLen = hb_arrayLen( pArray );
   PHB_ITEM pLast = hb_itemNew( NULL );

   if( ulLen )
   {
      hb_arrayLast( pArray, pLast );
      hb_arrayDel( pArray, ulLen );
      --ulLen;
      hb_arraySize( pArray, HB_MAX( ulLen, 0 ) );
   }

   hb_itemReturnRelease( pLast );
}


// tmppo:=BUSCACOMPLETA(tmpPos,STRING,len(BUSCA))

HB_FUNC( BUSCACOMPLETA )
{
   unsigned int pKey  = hb_parni( 1 );
   PHB_ITEM pSTRING = hb_param( 2, HB_IT_STRING );
   unsigned int pLen = hb_parni( 3 );  //len busca
   
   const char * t = hb_itemGetCPtr( pSTRING );

  // printf("\n%c  %c  %c  %c",*(t+pKey-1),*(t+pKey-1),*(t+pKey+pLen),*(t+pKey+pLen));
   if ( isalpha(*(t+pKey-2)) || isdigit(*(t+pKey-2)) || 
        isalpha(*(t+pKey+pLen-1)) || isdigit(*(t+pKey+pLen-1)) ) 
      hb_retni( 0 );
   else
      hb_retni( pKey );
   hb_itemClear( pSTRING );
}

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
/*
HB_FUNC ( CIF2STR )
{
   long long nNum = hb_parnd(1);
   char *buf = (char *) calloc(64,1);
   uint16_t size = sprintf(buf,"%.*lld",2, nNum);
   printf("%s\n\n\n",buf);
   hb_retc ( buf );
   free(buf);
}*/
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

HB_FUNC( GETLINEAS )
{
   PHB_ITEM pSTRING = hb_param( 1, HB_IT_STRING );
  // unsigned long nLen = hb_parnl( 2 );

   const char * STRING = hb_itemGetCPtr( pSTRING );
   unsigned long linea=0,noffset=0;

   PHB_ITEM pCWM = hb_itemArrayNew( 0 ); // CWM
   
   while (*STRING){
      // busca numero de linea
      linea=0; noffset=0;
      while(*STRING!=':'){
         linea = (linea * 10) + (*STRING - '0');
         ++STRING;    // avanzo un caracter.
      }
      ++STRING;  // omite ':'
      // busca desplazamiento
      while(*STRING!=':'){
         noffset = (noffset * 10) + (*STRING - '0');
         ++STRING;    // avanzo un caracter.
      }
      ++STRING;  // omite ':'
      
      PHB_ITEM pC = hb_itemArrayNew( 2 );
      hb_arraySetNL( pC, 1, linea );
      hb_arraySetNL( pC, 2, noffset );
      hb_arrayAdd( pCWM, pC );
      hb_itemRelease(pC);
      // resto de línea hasta '\n'
      while(*STRING!='\n') ++STRING;
      ++STRING;  // omite salto.
   }
   hb_itemClear( pSTRING );
   hb_itemReturnRelease( pCWM );

//   printf("\nnTotal=%ld\n",nTotal);
}

//HB_FUNC( GETENDFILE )
// nAvance:=GETINITFILE(inputFile,lini)   TAIL
/*HB_FUNC( GETINITFILE )
{
   const char * cFile = hb_parc( 1 );
   unsigned long nIni  = hb_parnl( 2 );

   
   FILE *fp;
   

   unsigned long nLin=0;
   unsigned long nTotCar=0;
   
   int sw=0;
   size_t vret;
   
 
      fp=fopen(cFile,"r");
      if (fp!=NULL){
         nLin = 0;
         while (!feof(fp)){
            char * buffer = (char *)calloc(512,1);
            vret = fread( buffer, 1, 512, fp);
            const char * cbuf = buffer;
            if (vret != 0 && !feof(fp)){
               // cuenta lineas
               nTotCar += vret;
               const char * ch;
               while ( (ch = strchr(cbuf,'\n')) != NULL ) {
                  ++nLin;
                  cbuf = cbuf + strlen( ch );
                  if (nLin == nIni-1){
                      sw=1;
                      nTotCar -= strlen(cbuf);
                      break;
                  }
               }
            }
            free(buffer);
            if(sw) break;
         }
      }
      fclose(fp);
   printf("LINEA TOPE=%ld, LINEA FINAL=%ld\n",nIni,nLin);
   hb_retnl(nTotCar);
} */
/*
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
*/
/*HB_FUNC( LEELINEA )
{
   PHB_ITEM pSTRING = hb_param( 2, HB_IT_STRING );
   int nPos = hb_parni( 3 );
   const char * t = hb_itemGetCPtr( pSTRING );
   FILE *fp;
   long pos
   fp=fopen(pFile,"r");
   fseek(fp,SEEK_CUR,);
   fclose(fp);
}*/
/*HB_FUNC( CUENTALINEAS )
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
} */
/*
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
}*/

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

//STRING:=COMGETLINEAS(cBUFF,NUMCAR,BUFFERLINEA) 
/*HB_FUNC( COMGETLINEAS )
{
   PHB_ITEM pSTRING = hb_param( 1, HB_IT_STRING );
   long nTotCar  = hb_parnl( 2 );
   long nMax  = hb_parnl( 3 );

   PHB_ITEM pCWM = hb_itemArrayNew( 0 ); // CWM
   const char * STRING = hb_itemGetCPtr( pSTRING );
   long j;
   long totalCar = 0;
   int sw=0;
   int swError=0;
   if (nMax<=0){
      nMax=1024;
   }
      char * cBuff;
      sw=1;
     // i=0;
      while( totalCar <= nTotCar ) {
         ///printf("DATO----- [%c] %d \n",*STRING,(int)*STRING);
         if (sw){
            cBuff = (char *)calloc(nMax+nMax,1);
            j=0;
            sw=0;      
         }
         if ( *STRING!='\n' ){
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
            if(j>=0){
               cBuff[j]='\0';
               const char * pBuffer = cBuff;
               PHB_ITEM pC  = hb_itemArrayNew( 1 );
               hb_arraySetC( pC, 1, (const char *) pBuffer  );
               hb_arrayAdd( pCWM, pC );
               hb_itemRelease( pC );
               free ( cBuff );
            }else{ 
               PHB_ITEM pC  = hb_itemArrayNew( 1 );
               hb_arraySetC( pC, 1, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
               hb_arrayAdd( pCWM, pC );
               hb_itemRelease( pC );
               free( cBuff );
               break;
            }            
            sw=1;
         }
      }
      if (swError) {
         PHB_ITEM pC  = hb_itemArrayNew( 1 );
         hb_arraySetC( pC, 1, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
         hb_arrayAdd( pCWM, pC );
         hb_itemRelease( pC );
         free ( cBuff );
      }
   
   hb_itemClear( pSTRING );
   hb_itemReturnRelease( pCWM );
}

HB_FUNC( GETLINEAS )
{
   PHB_ITEM pSTRING = hb_param( 1, HB_IT_STRING );
   long nTotal  = hb_parnl( 2 );
   long nTotCar  = hb_parnl( 3 );
   long nMax  = hb_parnl( 4 );
   int lini  = hb_parni( 5 );
   int lfin  = hb_parni( 6 );

   const char * STRING = hb_itemGetCPtr( pSTRING );
   long i;
   long totalCar = 0;
   int swError=0;
   if (nMax<=0){
      nMax=1024;
   }
//   if(lini==0) lini=1;
   if(lini>0){  // avanza el puntero del archivo:
      for(i=0;i<lini-1;i++){
         while( totalCar <= nTotCar ) {
            if ( *STRING=='\n'){
               ++totalCar;  // cuento el salto.
               ++STRING;    // avanzo un caracter.
               break;
            }else{
               ++totalCar;
               ++STRING;
            }
         }
      }
   }

   if(lfin>0) {
      if(lfin>nTotal) lfin=nTotal;
      else nTotal=lfin;   // ya no lee hasta el final...
   }
   nTotal -= (lini-1);
   PHB_ITEM pCWM = hb_itemArrayNew( nTotal ); // CWM

//   printf("\nnTotal=%ld\n",nTotal);
   for(i=1;i<=nTotal;i++){
      char * cBuff = (char *)calloc(nMax+nMax,1);
      long j=0;
      while( totalCar <= nTotCar ) {
         ///printf("DATO----- [%c] %d \n",*STRING,(int)*STRING);
         if ( *STRING!='\n'){
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
         hb_arraySetC( pCWM, i, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
         free ( cBuff );
         break;
      }
      if(j>=0){
         cBuff[j]='\0';
         const char * pBuffer = cBuff;
         hb_arraySetC( pCWM, i, (const char *) pBuffer );
   //               printf("Libera cBuff...\n");
         free ( cBuff );
         
   //               printf("Liberado!...\n");
      }else{ 
         hb_arraySetC( pCWM, i, (const char *) "ERROR-DE-FORMATO-NO-RECONOCIDO" );
         free( cBuff );
         break;
      }
      
   }
  // printf("\nnLEN LEIDOS=%ld\n",hb_arrayLen(pCWM));
   hb_itemClear( pSTRING );
   hb_itemReturnRelease( pCWM );
}*/

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

