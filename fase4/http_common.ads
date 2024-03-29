with Petition_Analysis; use Petition_Analysis;
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with Configuracion_Server; use Configuracion_Server;



package http_common is

   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

   --CONSTANTES DE CABECERAS Y CARACTERES DE FIN DE LINEA Y FIN DE DE CABECERA
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

   CABECERA400_11: constant String:=
     "HTTP/1.1 400 Bad Request";

   CABECERA404_11: constant String:=
     "HTTP/1.1 404 Not Found";

   CABECERA501_11: constant String:=
     "HTTP/1.1 501 Not Implemented";

   CABECERA200_11: constant String:=
     "HTTP/1.1 200 OK";
   ----------------------------------------------------------------------------------------

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return Boolean;

   function ExisteCampo(Peticion: in Petition_Type;
                        Campo: in ASU.Unbounded_String) return Boolean;

   procedure EnviarArchivo(Ruta: in ASU.Unbounded_String; Conexion: in out TCP.Connection;
                           Peticion: in Petition_Type);
   --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura, y el envio del archivo.
   --Ademas controla las excepciones, enviando la cabecera 404 si el archivo no se encontr�.

   procedure EnviarCabecera (Ruta: in ASU.Unbounded_String; Conexion: in out TCP.Connection;
                             Peticion: in Petition_Type);
   --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura del fichero para calcular
   --su tama�o. Adem�s, si el fichero no existe, salta una excepcion y envia el mensaje por la conex.

   procedure ComprobarCierreConexion(Peticion:in Petition_Type; FinConexion: out Boolean);
   --Inspecciona el campo connection, para variar o no el booleano global de cierre

   function EsHostValido(Peticion: in Petition_Type;
                         Configuracion: in TInfoConfiguracion) return Boolean;
      --Comprueba la validez del host, dependiendo del tipo de peticion.
      --���DE MOMENTO SOLO MIRA EL DOMINIO POR DEFECTO!!!!

end http_common;

