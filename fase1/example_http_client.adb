-- $Id$
--
-- Example of a simple HTTP client (using the simplified interface
--  provided by Lower_Layer_TCP)

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;

procedure Example_HTTP_Client is

   package TCP renames Lower_Layer_TCP;

   Usage_Error: exception;

   Serv_EP  : TCP.End_Point;
   Serv_Conn  : aliased TCP.Connection;
   PrimeraVez:Boolean:=TRUE;

   A_Char     : Character;
   Last       : Integer;
   A_String   : String (1 .. 80);
   End_of_Header_Line : String (1..2) := Ascii.CR & Ascii.LF;
   End_of_Header      : String (1..4) := End_of_Header_Line & End_of_Header_Line;


begin

   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   -- Creating TCP connection
      Serv_EP := TCP.Build (Ada.Command_Line.Argument (1),
                         Integer'Value (Ada.Command_Line.Argument (2)));
loop
   -- Connecting
   TCP.Connect (Serv_EP, Serv_Conn);

      -- Get petition from command line

      Ada.Text_IO.Get_Line (A_String, Last);


   -- Sending petition to server
      String'Write    (Serv_Conn'Access, A_String (1..Last));
      String'Write    (Serv_Conn'Access, End_of_Header (1..End_of_Header'Length));
      -- Character'Write (Serv_Conn'Access, Ascii.CR);
      -- Character'Write (Serv_Conn'Access, Ascii.LF);
      -- Character'Write (Serv_Conn'Access, Ascii.CR);
      -- Character'Write (Serv_Conn'Access, Ascii.LF);

      Ada.Text_IO.Put_Line ("Request sent, waiting for reply");

      -- Getting server answer. The loops exits when an Ada.UI:Exceptions.End_Error
      -- exception is raised because the server closed the connection.
      begin
         loop
            Character'Read (Serv_Conn'Access, A_Char);
            if A_Char /= Ascii.LF then
               Ada.Text_IO.Put (A_Char);
            else
               Ada.Text_IO.New_Line;
            end if;
         end loop;
      exception
         when Ada.IO_Exceptions.End_Error =>
            TCP.Dispose (Serv_Conn);
            Ada.Text_IO.Put ("puedes seguir pidiendo...");
            Ada.Text_IO.New_Line;
      end;
end loop;
exception
   when Ada.IO_Exceptions.End_Error =>
      TCP.Dispose (Serv_Conn);
      Ada.Text_IO.Put ("Connection closed by server");
      Ada.Text_IO.New_Line;
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Two arguments needed: host_no and port");
end Example_HTTP_Client;
