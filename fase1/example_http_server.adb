-- $Id$
--
-- Example of a simple HTTP server (using the simplified interface
--  provided by Lower_Layer_TCP)

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;

procedure Example_HTTP_Server is

   package TCP renames Lower_Layer_TCP;

   Usage_Error: exception;

   Serv_EP: TCP.End_Point;
   Serv_Conn: aliased TCP.Connection;

   A_Char: Character;
   End_of_Header_Line : String (1..2) := Ascii.CR & Ascii.LF;
   End_of_Header      : String (1..4) := End_of_Header_Line & End_of_Header_Line;

   LF_Found: Boolean := False;

   Dummy_Reply: String :=
     -- Reply header 
     "HTTP/1.0 200 OK" & End_of_Header_Line &
     "Content-Length: 205" & End_of_Header &
     -- Reply body
     "<!DOCTYPE HTML PUBLIC ""-//IETF//DTD HTML 2.0//EN"">" & Ascii.CR & Ascii.LF &
     "<HTML><HEAD>" & Ascii.CR & Ascii.LF &
     "<TITLE>CojoServer 0.0</TITLE>" & Ascii.CR & Ascii.LF &
     "</HEAD><BODY>" & Ascii.CR & Ascii.LF &
     "<H1>CojoServer 0.0</H1>" & Ascii.CR & Ascii.LF &
     "Your request was received and completely ignored!!!" & Ascii.CR & Ascii.LF &
     "</BODY></HTML>" & Ascii.CR & Ascii.LF;

begin
   if Ada.Command_Line.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   -- Creating TCP connection
   Serv_EP := TCP.Build (Ada.Command_Line.Argument (1),
                         Integer'Value (Ada.Command_Line.Argument (2)));
   -- Set connection ready to listen
   TCP.Listen_Connection (Serv_EP);

   loop
      -- Wait for connections
      Ada.Text_IO.Put_Line ("Waiting for remote connection");
      TCP.Wait_Connection (Serv_EP, Serv_Conn);
      Ada.Text_IO.Put_Line ("Connection accepted");

      -- Getting petition (it ends when two LFs are received)
      LF_Found:= False;
      loop
         Character'Read (Serv_Conn'Access, A_Char);
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
      
      -- Send reply
      String'Write (Serv_Conn'Access, Dummy_Reply);
      -- Close connection
      TCP.Dispose (Serv_Conn);
      Ada.Text_IO.Put_Line ("Connection closed by me");
   end loop;

exception
   when Ada.IO_Exceptions.End_Error =>
      TCP.Dispose (Serv_Conn);
      Ada.Text_IO.Put ("Connection closed by client");
      Ada.Text_IO.New_Line;
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Two arguments needed: host_no and port");
end Example_HTTP_Server;
