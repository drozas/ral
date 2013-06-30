-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: http_common
-- David Rozas Domingo
-- ------------------------------------------------------------

with Petition_Reply_Analysis; use Petition_Reply_Analysis;
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with Configuracion_Server; use Configuracion_Server;
with Unix; use Unix;


package http_common is

   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

   --CONSTANTES DE CABECERAS, PAGINAS PARA EL SERVER Y CARACTERES DE FIN DE LINEA Y FIN DE DE CABECERA
   ---------------------------------------------------------------------------------------
   End_of_Header_Line : constant String (1..2) := Ascii.CR & Ascii.LF;
   End_of_Header      : constant String (1..4) := End_of_Header_Line & End_of_Header_Line;

   CABECERA400_10: constant String:=
     "HTTP/1.0 400 Bad Request";

   CABECERA404_10: constant String:=
     "HTTP/1.0 404 Not Found";

   CABECERA501_10: constant String:=
     "HTTP/1.0 501 Not Implemented";

   CABECERA200_10: constant String:=
     "HTTP/1.0 200 OK";

   CABECERA505_10: constant string:=
     "HTTP/1.1 505 HTTP Version Not Supported";

   CABECERA403_10: constant String:=
     "HTTP/1.0 403 Forbidden";

   CABECERA502_10: constant String:=
     "HTTP/1.0 502 Bad Gateway";

   CABECERA504_10: constant String:=
     "HTTP/1.0 504 Gateway Timeout";

   ---------------------------------------------------------------------------------
   CABECERA400_11: constant String:=
     "HTTP/1.1 400 Bad Request";

   CABECERA404_11: constant String:=
     "HTTP/1.1 404 Not Found";

   CABECERA501_11: constant String:=
     "HTTP/1.1 501 Not Implemented";

   CABECERA200_11: constant String:=
     "HTTP/1.1 200 OK";

   CABECERA403_11: constant String:=
     "HTTP/1.1 403 Forbidden";

   CABECERA502_11: constant String:=
     "HTTP/1.1 502 Bad Gateway";

   CABECERA504_11: constant String:=
     "HTTP/1.1 504  Gateway Timeout";

   --------------------------------------------------------------------------


   PAG404: constant String:="<html><head><title>¡Error!: 404 Not Found </title></head><body><h1><p>404: NOT FOUND</p></h1><h2><p>La pagina solicitada no se encuentra en este servidor.</p></h2></body></html>";
   TAM_PAG404: constant Natural:= ASU.Length(ASU.To_Unbounded_String(PAG404));

   PAG403: constant String:="<html><head><title>¡Error!: 403 Forbidden </title></head><body><h1><p>403: FORBIDDEN</p></h1><h2><p>No tienes permisos de acceso.</p></h2></body></html>";
   TAM_PAG403: constant Natural:= ASU.Length(ASU.To_Unbounded_String(PAG403));

   PAG501: constant String:="<html><head><title>¡Error!: 501 Not Implemented </title></head><body><h1><p>501: NOT IMPLEMENTED</p></h1><h2=><p>La acción solicitada no está implementada en este serrvidor.</p></h2></body></html>";
   TAM_PAG501: constant Natural:= ASU.Length(ASU.To_Unbounded_String(PAG501));

   PAG502: constant String:="<html><head><title>¡Error!: 502 Bad Gateway </title></head><body><h1><p>502: BAD GATEWAY</p></h1><h2=><p>Ningun servidor sirve ese nombre</p></h2></body></html>";
   TAM_PAG502: constant Natural:= ASU.Length(ASU.To_Unbounded_String(PAG502));

   PAG504: constant String:="<html><head><title>¡Error!: 504 Gateway Timeout </title></head><body><h1><p>504: GATEWAY TIMEOUT</p></h1><h2=><p>Respuesta inesperada del servidor remoto</p></h2></body></html>";
   TAM_PAG504: constant Natural:= ASU.Length(ASU.To_Unbounded_String(PAG504));

   ----------------------------------------------------------------------------------
   procedure EnviarArchivo(Ruta: in ASU.Unbounded_String;
                           Conexion: in out TCP.Connection;
                           Peticion: in Petition_Type;
                           FinConexion: in Boolean;
                           flagMaxConn: in Boolean);
   --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura, y el envio del archivo.
   --Ademas controla las excepciones, enviando la cabecera 404 si el archivo no se encontró.

   procedure EnviarCabecera (Ruta: in ASU.Unbounded_String;
                             Conexion: in out TCP.Connection;
                             Peticion: in Petition_Type;
                             FinConexion: in Boolean;
                             flagMaxConn: in Boolean);
   --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura del fichero para calcular
   --su tamaño. Además, si el fichero no existe, salta una excepcion y envia el mensaje por la conex.

   procedure EnviarPost(Ruta: in out ASU.Unbounded_String;
                        Conexion: in out TCP.Connection;
                        Peticion: in out Petition_Type;
                        FinConexion: in Boolean;
                        flagMaxConn: in Boolean);
   --Recibe una ruta, y la conexion. Se encarga de ejecutar el  fichero cgi, y de  calcular
   --su tamaño de respuesta.


-------------------------------------------------------------------------------------------------------
   procedure ComprobarCierreConexion(Peticion:in Petition_Type;
                                     FinConexion: out Boolean);
   --Inspecciona el campo connection, para variar o no el booleano global de cierre

   procedure ComprobarCierreConexionEnRemota(Peticion:in Petition_Type;
                                             FinConexion:out Boolean);
   --Se encarga de determinar si hay que cerrar la conexion con el cliente en peticiones remotas.
   --Inspecciona los campos Connection, y Proxy-Connection


   function EsHostLocalValido(Peticion: in Petition_Type;
                              Configuracion: in TInfoConfiguracion) return ASU.Unbounded_String;
   --Comprueba la validez del host, dependiendo del tipo de peticion.
   --¡¡¡DE MOMENTO SOLO MIRA EL DOMINIO POR DEFECTO!!!!

   function EsHostRemotoValido(Peticion: in Petition_Type ) return ASU.Unbounded_String;
   -- Si la primºra línea de la petición trae una URI completa y el dominio solicitado no es el local
   -- No tiene en cuenta el campo host

   procedure LeerCabecera(Conexion: in out TCP.Connection;
                          CadenaDevuelta: out ASU.Unbounded_String);
   --Lee la cabecera de la conexión

   procedure EsDominioServido(Host:in out  Asu.Unbounded_String;
                             Configuracion: in TInfoConfiguracion;
                             EsServido: out Boolean);
   --Chequea un host, para ver si pertenece a nuestro conjunto de dominios o nuestra ip; informandonos por el booleano
   --Ademas si el host lleva port, modifica su valor eliminandolo: www.lala.com:666 -> www.lala.com
   -------------------------------------------------------------------------------------------------------
end http_common;

