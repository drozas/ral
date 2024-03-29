-- PR�CTICA RAL: Servidor HTTP
-- David Rozas

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;
with Petition_Analysis; use Petition_Analysis;
with Http_10; use http_10;
with http_Aux; use http_Aux;
with Ada.Strings.Unbounded;
with Uri_Analysis; use Uri_Analysis;
with configuracion_server; use configuracion_server;

procedure server is

   package TCP renames Lower_Layer_TCP;
   package ASU renames ada.strings.unbounded;
   use type ASU.Unbounded_String;

   Usage_Error: exception;

   Serv_EP: TCP.End_Point;
   Serv_Conn: aliased TCP.Connection;

   A_Char: Character;

   LF_Found: Boolean := False;
   CadenaPeticion: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
   Peticion: Petition_Type;
   NPeticion: Integer;
   Configuracion: TInfoConfiguracion;

begin
   --Controlamos que sea correcto el n� de argumentos
   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   -- Creacion de end point, y puesta a escucha
   Serv_EP := TCP.Build (Ada.Command_Line.Argument (1),
                         Integer'Value (Ada.Command_Line.Argument (2)));
   TCP.Listen_Connection (Serv_EP);
   -- Adem�s, cargamos la configuracion del servidor...
   CargarConfiguracion(Configuracion);

   loop
      --Inicializaci�n de variables
      cadenaPeticion:=ASU.Null_Unbounded_String;
      NPeticion:=1;

      -- Esperamos a que nos hagan peticiones
      Ada.Text_IO.Put_Line ("Arrancando server. Esperando a recibir conexiones...");
      TCP.Wait_Connection (Serv_EP, Serv_Conn);
      Ada.Text_IO.Put_Line ("Recibida una petici�n...");

      -- Lectura de la peticion
      LF_Found:= False;

      -- Lectura de la peticion, y la guardamos en un unbounded
      Ada.Text_Io.Put_Line("->LEYENDO PETICION N�: " & Integer'Image(NPeticion));
      NPeticion:=nPeticion+1;
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
         Ada.Text_Io.Put_line("Llamada a Analyze_Petition");

         if Peticion.Version=Petition_Analysis.V10 then
            -- Llamamos a la funcion de atender peticiones, del paquete Http10
            Ada.Text_Io.Put_Line("Peticion de tipo HTTP 1.0");
            http_10.Attend_Petition(Peticion,Serv_Conn,configuracion);
         elsif Peticion.Version=Petition_Analysis.V11 then
            -- Respondemos diciendo que aun no esta implementado
                        Ada.Text_Io.Put_Line("Peticion de tipo HTTP 1.1");
            String'Write(Serv_Conn'access, CABECERA505);
         else
            -- Excepcion, version distinta de 1.1 o 1.0: BAD request
                        Ada.Text_Io.Put_Line("Peticion de tipo distino a 1.1 o 1.0.");
            String'Write(Serv_Conn'access,CABECERA400);
         end if;

      exception
         when Petition_Analysis.Bad_Syntax =>
            Ada.Text_Io.Put_Line("Bad Request del SERVER!!!");
            String'Write(Serv_Conn'access, CABECERA400);
      end;
      -- Liberar conexion
      TCP.Dispose (Serv_Conn);
      Ada.Text_IO.Put_Line ("El servidor ha cerrado la conexi�n...");

   end loop;

exception
   when Ada.IO_Exceptions.End_Error =>
      TCP.Dispose (Serv_Conn);
      Ada.Text_IO.Put ("El cliente ha cerrado la conexi�n...");
      Ada.Text_IO.New_Line;
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Dos argumentos necesarios: host y port");

end server;
