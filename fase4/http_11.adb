package body http_11 is

-------------------------------------------------------------------------------------------------------

   procedure Attend_GET_Petition(Peticion: in Petition_Type;
                                 Conexion: in out TCP.Connection; Configuracion: in TInfoConfiguracion;
                                 FinConexion:in out Boolean) is
   -- Procedimiento que implementa el metodo GET de version 1.1
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.Put_Line("Atendiendo peticion GET de HTTP 1.1");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Miramos si hay cabecera Close
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion)) & Peticion.Uri.Path;
         --Y enviamos el archivo completo
         Http_Common.EnviarArchivo(Ruta,Conexion,Peticion);


      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request de GET)");
         String'Write(conexion'access, CABECERA400_11 & Http_Common.End_Of_Header);
         --Forzamos el cierre de conexion por BR, a traves del booleano global
         FinConexion:=TRUE;
      end if;

   end Attend_GET_Petition;

---------------------------------------------------------------------------------------------------------

procedure Attend_HEAD_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                              Configuracion: in TInfoConfiguracion; FinConexion: in out Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el HEAD de 1.1");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if Http_Common.EsHostValido(Peticion,configuracion) then
         --Miramos si hay cabecera Close
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);
         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion)) & Peticion.Uri.Path;
         --Enviamos la cabecer
         Http_Common.EnviarCabecera(Ruta,Conexion,Peticion);

      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request del HEAD)");
         String'Write(conexion'access, CABECERA400_11 & Http_Common.End_Of_Header);
         --Forzamos el cierre de conexion, a traves del booleano global
         FinConexion:=TRUE;

      end if;

   end Attend_HEAD_Petition;
----------------------------------------------------------------------------------------------------------


   procedure Attend_Petition_http11(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                                    Configuracion: in TInfoConfiguracion; FinConexion: in out Boolean) is
   --Este procedimiento distribuye los metodos de tipo 1.0 de cada petición

   begin

      --De momento solo contempla los metodos GET y HEAD
      if Peticion.Method= Petition_Analysis.GET then
         Attend_GET_Petition(Peticion,Conexion,Configuracion,finConexion);
      elsif Peticion.Method= Petition_Analysis.HEAD then
         Attend_HEAD_Petition(Peticion,Conexion,Configuracion,FinConexion);
      else
         String'Write(conexion'access, CABECERA501_11 & Http_Common.End_Of_header);
         --Miramos si hay cabecera Close
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);
      end if;

   end Attend_Petition_http11;

------------------------------------------------------------------------------------------------------

end http_11;
