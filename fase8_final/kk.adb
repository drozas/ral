--with Petition_Reply_Analysis; use Petition_Reply_Analysis;
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with Lower_Layer_TCP;
--with Ada.IO_Exceptions;
--with Ada.Exceptions;
--with Ada.Text_IO;
--with Ada.Streams.Stream_IO;
--with Configuracion_Server; use Configuracion_Server;
--with Unix; use Unix;
--llamadas a paquetes necesarios para conseguir la ip
with Lower_Layer.Inet.Misc;
with Ada_Sockets;


procedure Test_ip is
   IP_MAQUINA: constant String:= Lower_Layer.Inet.Misc.To_IP(Ada_Sockets.Get_Host_Name);
begin
   Ada.Text_Io.Put_Line("Ip de mi máquina : " & IP_MAQUINA);

end Test_ip;
