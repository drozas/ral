with Ada.Strings.Unbounded;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with http_common; use Http_common;
with Petition_Analysis; use Petition_Analysis;
with Configuracion_Server; use Configuracion_Server;

package http_11 is

   package ASU renames Ada.Strings.Unbounded;
   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   use type ASU.Unbounded_String;


   procedure Attend_Petition_http11(Peticion: in out Petition_Type;
                                    Conexion: in out TCP.Connection;
                                    Configuracion: in TInfoConfiguracion;
                                    FinConexion: in out Boolean;
                                    flagMaxConn: in Boolean);
   --Solo es visible la que hace el tratamiento general
   --Nota: peticion entra como in out. Pero solo es modificada en el de POST. en el resto, de momento
   --     solo se le trata como in

end http_11;
