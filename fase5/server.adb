-- PRÁCTICA RAL: Servidor HTTP
-- David Rozas

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;
with Petition_Analysis; use Petition_Analysis;
with Http_10; use http_10;
with http_common; use http_common;
with Ada.Strings.Unbounded;
with Uri_Analysis; use Uri_Analysis;
with configuracion_server; use configuracion_server;
with Http_11; use Http_11;


procedure server is

   package TCP renames Lower_Layer_TCP;
   package ASU renames ada.strings.unbounded;
   use type ASU.Unbounded_String;

   MAX_PETICIONES: Integer:= 69;
   Usage_Error: exception;

   Serv_EP: TCP.End_Point;
   Serv_Conn: aliased TCP.Connection;

   A_Char: Character;

   LF_Found: Boolean := False;
   CadenaPeticion: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
   Peticion: Petition_Type;
   NPeticiones: Integer;
   Configuracion: TInfoConfiguracion;
   finConexion: Boolean;
   flagMaxConn: Boolean:= False;

begin
   --  Controlamos que sea correcto el nº de argumentos
   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   -- Creacion de end point, y puesta a escucha
   Serv_EP := TCP.Build (Ada.Command_Line.Argument (1),
                         Integer'Value (Ada.Command_Line.Argument (2)));
   TCP.Listen_Connection (Serv_EP);
   -- Además, cargamos la configuracion del servidor...
   CargarConfiguracion(Configuracion);
   MAX_PETICIONES:= Get_MaxPeticiones(Configuracion);

   loop
      --Inicializamos variables ...
      NPeticiones:=0;
      flagMaxConn:=FALSE;
      -- Esperamos a que nos hagan conexiones
      Ada.Text_IO.Put_Line ("Esperando a recibir conexiones...");
      TCP.Wait_Connection (Serv_EP, Serv_Conn);
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("");
      Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Inicio de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
      --Cerraremos la conexion despues de 5 seguidas, o cuando lo marque el booleano
      loop
         --Inicialización de variables
         FinConexion:=FALSE;
         cadenaPeticion:=ASU.Null_Unbounded_String;

         NPeticiones:=NPeticiones+1;

         --Si es la 5ª peticion, avisaremos a los modulos internos de que tienen que agregar
         --el campo de Connection: Close
         if NPeticiones=MAX_PETICIONES then
            flagMaxConn:= TRUE;
         end if;

         -- Lectura de la peticion
         LF_Found:= False;
         loop
            Character'Read (Serv_Conn'Access, A_Char);
            CadenaPeticion:=CadenaPeticion & A_Char;
            case A_Char is
               when Ascii.LF =>
                  Ada.Text_IO.Put_Line ("(LF)");
                  exit when LF_Found;
                  LF_Found:= True;
               when Ascii.CR =>
                  Ada.Text_IO.Put ("(CR)");
               when others =>
                  Ada.Text_IO.Put (A_Char);
                  LF_Found:= False;
            end case;
         end loop;

         begin
            Analyze_Petition(cadenaPeticion,Peticion);

            if Peticion.Version=Petition_Analysis.V10 then
               -- Llamamos a la funcion de atender peticiones, del paquete Http10
               Ada.Text_Io.Put_Line("Vamos a tratar una peticion de tipo HTTP 1.0");
               http_10.Attend_Petition_http10(Peticion,Serv_Conn,Configuracion,FinConexion,flagMaxConn);

            elsif Peticion.Version=Petition_Analysis.V11 then
               -- Llamamos a la funcion de atender peticiones, del paquete http11
               Ada.Text_Io.Put_Line("Vamos a tratar una peticion de  tipo HTTP 1.1");
               http_11.Attend_Petition_Http11(Peticion,Serv_Conn,Configuracion,FinConexion,flagMaxConn);

            end if;

         exception
            when Petition_Analysis.Bad_Syntax =>
               Ada.Text_Io.Put_Line("Bad Request del SERVER!!!");
               --Liberaremos la conexion si hubo un Bad Request. Escribimos la cabecera...
               String'Write(Serv_Conn'access, CABECERA400_10 & Http_Common.End_Of_Header_Line);
               --y el connection_close
               String'Write(Serv_Conn'Access, "Connection: Close" & Http_Common.End_Of_Header);
               FinConexion:=TRUE;
         end;

         if FinConexion then
            --Si se cerro la conexion por mandato de alguna cabecera...
            --¿¿¿Es aquí donde metemos el connection close, no?
            Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Cierre de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
            Ada.Text_Io.Put_Line("El servidor ha cerrado la conexion.");
            TCP.Dispose (Serv_Conn);
         elsif NPeticiones>=MAX_PETICIONES then
            --Si fue por nº de peticiones, el connection close se supone que ya lo hemos enviado
            FinConexion:=TRUE;
            Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Cierre de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
            Ada.Text_Io.Put_line("El servidor cierra la conexion, despues de 5 conexiones seguidas.");
            TCP.Dispose (Serv_Conn);
         end if;

         exit when FinConexion;
      end loop;


   end loop;

exception
   when Ada.IO_Exceptions.End_Error =>
      TCP.Dispose (Serv_Conn);
      Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Cierre de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
      Ada.Text_IO.Put ("El cliente ha cerrado la conexión...");
      Ada.Text_IO.New_Line;
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Dos argumentos necesarios: host y port");

end server;
