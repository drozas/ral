-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: http_11
-- David Rozas Domingo
-- ------------------------------------------------------------

with Ada.Strings.Unbounded;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with http_common; use Http_common;
with Petition_Reply_Analysis; use Petition_Reply_Analysis;
with Configuracion_Server; use Configuracion_Server;

package http_11 is

   package ASU renames Ada.Strings.Unbounded;
   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   use type ASU.Unbounded_String;


   procedure Attend_Petition_http11(Peticion: in out Petition_Type;
                                    Conexion: in out TCP.Connection;
                                    Configuracion: in TInfoConfiguracion;
                                    HostDevuelto: in ASU.Unbounded_String;
                                    FinConexion: in out Boolean;
                                    flagMaxConn: in Boolean);
   --NOTA: Peticion entra como in out, pero solo se trata como in out en el tratamiento
   -- del post. En el resto va como in!

end http_11;
