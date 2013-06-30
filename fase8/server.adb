-- PRÁCTICA RAL: Servidor HTTP
-- David Rozas

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;
with Ada.Strings.Unbounded;
with Tarea_Conexion;
with configuracion_server; use configuracion_server;

procedure server is

   package TCP renames Lower_Layer_TCP;
   package ASU renames ada.strings.unbounded;
   use type ASU.Unbounded_String;


   Usage_Error: exception;
   Serv_EP: TCP.End_Point;
   NHijos:  Natural:=1;
   Hijo: Tarea_Conexion.PHijo;
   DatosTarea: Tarea_Conexion.PInfoTarea;
   Configuracion_Estandar: TInfoConfiguracion;


begin
   --  Controlamos que sea correcto el nº de argumentos
   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   -- Creacion de end point, y puesta a escucha
   Serv_EP := TCP.Build (Ada.Command_Line.Argument (1),
                         Integer'Value (Ada.Command_Line.Argument (2)));
   TCP.Listen_Connection (Serv_EP);
   -- Además, cargamos la configuracion del servidor en una auxiliar, para tener que hacerlo una sola vez
   CargarConfiguracion(Configuracion_Estandar,ASU.To_Unbounded_String(Ada.Command_Line.Argument(1)),
                       ASU.To_Unbounded_String(Ada.Command_Line.Argument(2)));
   loop

      --Creamos un nuevo registro
      DatosTarea := new Tarea_Conexion.InfoTarea;
      --Y ahora se la pasamos..
      DatosTarea.Configuracion:=Configuracion_Estandar;
      -- Esperamos a que nos hagan conexiones
      Ada.Text_IO.Put_Line ("Esperando a recibir conexiones...");
      TCP.Wait_Connection (Serv_EP, DatosTarea.Conexion);
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@ Inicio de conexion @@@@@@@@@@@@@@@@");

      --LLAMADA A NUEVA_CONEXION
      Ada.Text_Io.Put_Line("Creando el HIJO Nº : " & Natural'Image(NHijos));
      NHijos:=NHijos+1;
      --Y una nueva tarea
      Hijo := new Tarea_Conexion.NuevaConexion(DatosTarea);
   end loop;

exception
   when Ada.IO_Exceptions.End_Error =>
      TCP.Dispose (DatosTarea.Conexion);
      Ada.Text_Io.Put_Line("@@@@@@ Cierre de conexion: El cliente cerró la conexión @@@@@@");
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Dos argumentos necesarios: host y port");

end server;
