-- ------------------------------------------------------------
--       Pr�ctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- M�dulo: test_ip (programa para probar la funciones
--                  de obtenci�n de ip)
-- David Rozas Domingo
-- ------------------------------------------------------------
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with Lower_Layer_TCP;
with Lower_Layer.Inet.Misc;
with Ada_Sockets;


procedure Test_ip is
   IP_MAQUINA: constant String:= Lower_Layer.Inet.Misc.To_IP(Ada_Sockets.Get_Host_Name);
begin
   Ada.Text_Io.Put_Line("Ip de mi m�quina : " & IP_MAQUINA);

end Test_ip;
