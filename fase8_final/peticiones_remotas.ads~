with Ada.Strings.Unbounded;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with http_common; use Http_common;
with Petition_Reply_Analysis; use Petition_Reply_Analysis;
with Configuracion_Server; use Configuracion_Server;
with Lower_Layer.Inet.Misc; Use Lower_Layer.Inet.Misc;
with Ada_Sockets; use Ada_Sockets;
package Peticiones_remotas is

   package ASU renames Ada.Strings.Unbounded;
   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   use type ASU.Unbounded_String;

   procedure Attend_Remote_Petition (Peticion: in out Petition_Type;
                                     Conexion: in out TCP.Connection;
                                     FinConexion: in out Boolean;
                                     flagMaxConn: in Boolean);
   --La única función visible es la de tratamiento de peticion.
   --NOTA: Peticion entra como in out, pero puede que tenga que ir mejor como in!

end Peticiones_remotas;
