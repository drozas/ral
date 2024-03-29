with Ada.Strings.Unbounded;
with Lower_Layer_TCP;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with http_Aux; use http_Aux;
with Petition_Analysis; use Petition_Analysis;

package http10 is

   package ASU renames Ada.Strings.Unbounded;
   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   use type ASU.Unbounded_String;

   procedure Attend_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection);
   -- Procedimiento general de atencion de peticiones de http10

   procedure Attend_GET_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection);
   -- Tratamiento del metodo get

   procedure Attend_HEAD_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection);
   -- Tratamiento del metodo head


end http10;
