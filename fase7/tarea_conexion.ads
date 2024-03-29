with Lower_Layer_TCP;
with Ada.Text_IO;
with Petition_Reply_Analysis; use Petition_Reply_Analysis;
with Http_10; use http_10;
with http_common; use http_common;
with Ada.Strings.Unbounded;
with Uri_Analysis; use Uri_Analysis;
with configuracion_server; use configuracion_server;
with Http_11; use Http_11;
with Ada.Streams.Stream_Io;
with Peticiones_Remotas; use Peticiones_Remotas;

package Tarea_Conexion is

   package TCP renames Lower_Layer_TCP;
   package SIO renames Ada.Streams.Stream_Io;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;


   --Creamos un tipo registro con la info de la tarea, que de momento solo contiene la conexion
   type InfoTarea is record
      Conexion: aliased TCP.Connection;
      Configuracion: TInfoConfiguracion;
   end record;

   --Y un tipo puntero a dicho regitro
   type pInfoTarea is access InfoTarea;

   --Declaro aqu� la tarea
   task type NuevaConexion (pDatosTarea: pInfoTarea) is
      --NO HAY ESPECIFICACION
   end NuevaConexion;

   --y aqui tb el tipo puntero al task
   type pHijo is access NuevaConexion;

end Tarea_Conexion;
