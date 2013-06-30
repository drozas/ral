package body http_10 is
-------------------------------------------------------------------------------------------------------
   procedure Attend_GET_Petition(Peticion: in Petition_Type;
                                 Conexion: in out TCP.Connection;
                                 Configuracion: in TInfoConfiguracion;
                                 HostDevuelto: in ASU.Unbounded_String;
                                 FinConexion: in out Boolean;
                                 flagMaxConn: in Boolean) is
   -- Procedimiento que implementa el metodo GET de version 1.0
      Ruta: ASU.Unbounded_String;
   begin


      Ada.Text_Io.Put_Line("Atendiendo peticion GET de HTTP 1.0");

      --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
      Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

      --Formamos la ruta
      Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion)) & ASU.To_String(HostDevuelto) & Peticion.Uri.Path;
      Ada.Text_Io.Put_Line("ruta formada: " & ASU.To_String(Ruta));
      --Y enviamos el archivo completo
      --Enviamos tb el finConexion en modo lectura, para saber si hay que agregar campo connClose
      Http_Common.EnviarArchivo(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);

   end Attend_GET_Petition;

---------------------------------------------------------------------------------------------------------

   procedure Attend_HEAD_Petition(Peticion: in Petition_Type;
                                  Conexion: in out TCP.Connection;
                                  Configuracion: in TInfoConfiguracion;
                                  HostDevuelto: in ASU.Unbounded_String;
                                  FinConexion:in out Boolean;
                                  flagMaxConn: in Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.Put_Line("Atendiendo el Head de 1.0");
      --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
      Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

      --Formamos la ruta
      Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion))  & ASU.To_String(HostDevuelto) & Peticion.Uri.Path;
      Ada.Text_Io.Put_Line("ruta formada: " & ASU.To_String(Ruta));
      --Y enviamos la cabecera
      Http_Common.EnviarCabecera(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);

   end Attend_HEAD_Petition;


----------------------------------------------------------------------------------------------------------


   procedure Attend_POST_Petition(Peticion: in out Petition_Type;
                                  Conexion: in out TCP.Connection;
                                  Configuracion: in TInfoConfiguracion;
                                  HostDevuelto: in ASU.Unbounded_String;
                                  FinConexion:in out Boolean;
                                  flagMaxConn: in Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el POST de 1.0...");
      --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
      Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

      --Formamos la ruta
      Ruta:= Get_DirectorioArchivos(Configuracion) & ASU.To_String(HostDevuelto) & Peticion.Uri.Path;
      Ada.Text_Io.Put_Line("ruta formada: " & ASU.To_String(Ruta));
      --Y enviamos la cabecera
      Http_Common.EnviarPost(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);

   end Attend_POST_Petition;
   ----------------------------------------------------------------------------------------------------------


   procedure Attend_Petition_http10(Peticion: in out Petition_Type;
                                    Conexion: in out TCP.Connection;
                                    Configuracion: in TInfoConfiguracion;
                                    HostDevuelto: in ASU.Unbounded_String;
                                    FinConexion: in out Boolean;
                                    flagMaxConn: in Boolean) is
      --Este procedimiento distribuye los metodos de tipo 1.0 de cada petición
   begin
      --################ TRATAMIENTO DE PETICIONES LOCALES DE TIPO 1.0 #####################
      if Peticion.Method= Petition_Reply_Analysis.GET then
         Attend_GET_Petition(Peticion,Conexion,Configuracion,HostDevuelto,FinConexion,flagMaxConn);
      elsif Peticion.Method= Petition_Reply_Analysis.HEAD then
         Attend_HEAD_Petition(Peticion,Conexion,Configuracion,HostDevuelto,FinConexion,flagMaxConn);
      elsif Peticion.Method= Petition_Reply_Analysis.POST then
         Attend_POST_Petition(Peticion,Conexion,Configuracion,HostDevuelto,FinConexion,flagMaxConn);
      else
         String'Write(conexion'access, CABECERA501_10 & Http_Common.End_Of_Header_line);
         --Comprobamos por ultimo, si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Agregamos además una web explicando el error
         String'Write(Conexion'Access, "Content-Length:" & Natural'Image(TAM_PAG501));
         --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
         if flagMaxConn or flagMaxConn then
            String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                         & "Connection: Close" & Http_Common.End_Of_Header);
         else
            String'Write(Conexion'Access, Http_Common.End_Of_Header);
         end if;
         String'Write(Conexion'Access,PAG501);
      end if;
      --####################################################################################

   end Attend_Petition_Http10;

   ------------------------------------------------------------------------------------------------------


end http_10;
