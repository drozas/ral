with Ada.Strings.Unbounded;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with http_common; use Http_common;
with Petition_Analysis; use Petition_Analysis;
with Configuracion_Server; use Configuracion_Server;

package http_10 is

   package ASU renames Ada.Strings.Unbounded;
   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   use type ASU.Unbounded_String;

   procedure Attend_Petition_http10(Peticion: in out Petition_Type;
                                    Conexion: in out TCP.Connection;
                                    Configuracion: in TInfoConfiguracion;
                                    FinConexion: in out Boolean;
                                    flagMaxConn: in Boolean);
   --La única función visible es la de tratamiento de peticion.
   --NOTA: Peticion entra como in out, pero de momento solo se trata como in out en el tratamiento
   -- del post. En el resto va como in!

end http_10;
