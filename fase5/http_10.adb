package body http_10 is
-------------------------------------------------------------------------------------------------------
   procedure Attend_GET_Petition(Peticion: in Petition_Type;
                                 Conexion: in out TCP.Connection;
                                 Configuracion: in TInfoConfiguracion;
                                 FinConexion: in out Boolean;
                                 flagMaxConn: in Boolean) is
   -- Procedimiento que implementa el metodo GET de version 1.0
      Ruta: ASU.Unbounded_String;
   begin


      Ada.Text_Io.Put_Line("Atendiendo peticion GET de HTTP 1.0");
      --Comprobacion del dominio
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion)) & Peticion.Uri.Path;
         --Y enviamos el archivo completo
         --Enviamos tb el finConexion en modo lectura, para saber si hay que agregar campo connClose
         Http_Common.EnviarArchivo(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);
      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request de GET)");
         --Devolvemos la cabecera y EL CONNECTION CLOSE!
         String'Write(conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_Line);
         String'Write(Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
         --Cerramos la conexion forzosamente, por Bad Request
         FinConexion:=TRUE;
      end if;


   end Attend_GET_Petition;

---------------------------------------------------------------------------------------------------------

   procedure Attend_HEAD_Petition(Peticion: in Petition_Type;
                                  Conexion: in out TCP.Connection;
                                  Configuracion: in TInfoConfiguracion;
                                  FinConexion:in out Boolean;
                                  flagMaxConn: in Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el Head de 1.0");
      --Comprobacion del dominio
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion))  & Peticion.Uri.Path;
         --Y enviamos la cabecera
         Http_Common.EnviarCabecera(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);

      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request del HEAD)");
         -- Escribimos cabecera y CONNECTION CLOSE!
         String'Write(conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_Line);
         String'Write(Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
         --Cerramos la conexion forzosamente, por Bad Request
         FinConexion:=TRUE;

      end if;

   end Attend_HEAD_Petition;


----------------------------------------------------------------------------------------------------------


   procedure Attend_POST_Petition(Peticion: in out Petition_Type;
                                  Conexion: in out TCP.Connection;
                                  Configuracion: in TInfoConfiguracion;
                                  FinConexion:in out Boolean;
                                  flagMaxConn: in Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el POST de 1.0...");
      --Comprobacion del dominio
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:= Get_DirectorioArchivos(Configuracion) & Peticion.Uri.Path;
         --Y enviamos la cabecera
         Http_Common.EnviarPost(Ruta,Conexion,Peticion,FinConexion,flagMaxConn);

      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request del POST)");
         --Vamos a cerrar...asi ke cabecera y Connection close
         String'Write(conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_line);
         String'Write(Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
         --Cerramos la conexion forzosamente, por Bad Request
         FinConexion:=TRUE;

      end if;

   end Attend_POST_Petition;
----------------------------------------------------------------------------------------------------------


procedure Attend_Petition_http10(Peticion: in out Petition_Type;
                                 Conexion: in out TCP.Connection;
                                 Configuracion: in TInfoConfiguracion;
                                 FinConexion: in out Boolean;
                                 flagMaxConn: in Boolean) is
   --Este procedimiento distribuye los metodos de tipo 1.0 de cada petición
   begin


      --De momento solo contempla los metodos GET y HEAD
      if Peticion.Method= Petition_Analysis.GET then
         Attend_GET_Petition(Peticion,Conexion,Configuracion,FinConexion,flagMaxConn);
      elsif Peticion.Method= Petition_Analysis.HEAD then
         Attend_HEAD_Petition(Peticion,Conexion,Configuracion,FinConexion,flagMaxConn);
      elsif Peticion.Method= Petition_Analysis.POST then
         Attend_POST_Petition(Peticion,Conexion,Configuracion,FinConexion,flagMaxConn);
      else
         String'Write(conexion'access, CABECERA501_10);
         --Comprobamos por ultimo, si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
         if flagMaxConn or flagMaxConn then
            String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                         & "Connection: Close" & Http_Common.End_Of_Header);
         else
            String'Write(Conexion'Access, Http_Common.End_Of_Header);
         end if;
      end if;

   end Attend_Petition_Http10;

------------------------------------------------------------------------------------------------------


end http_10;
