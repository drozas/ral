package body http_10 is

-----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
   procedure Attend_GET_Petition(Peticion: in Petition_Type;
                                 Conexion: in out TCP.Connection; Configuracion: in TInfoConfiguracion;
                                 FinConexion: out Boolean) is
   -- Procedimiento que implementa el metodo GET de version 1.0
      Ruta: ASU.Unbounded_String;
   begin


      Ada.Text_Io.Put_Line("Atendiendo peticion GET de HTTP 1.0");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion)) & Peticion.Uri.Path;
         --Y enviamos el archivo completo
         Http_Common.EnviarArchivo(Ruta,Conexion,Peticion);
      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request de GET)");
         String'Write(conexion'access, CABECERA400_10 & Http_Common.End_Of_Header);
         --Cerramos la conexion forzosamente, por Bad Request
         FinConexion:=TRUE;
      end if;


   end Attend_GET_Petition;

---------------------------------------------------------------------------------------------------------

procedure Attend_HEAD_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                              Configuracion: in TInfoConfiguracion; FinConexion:out Boolean) is
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el Head...");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if Http_Common.EsHostValido(Peticion,configuracion) then

         --Comprobamos si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);

         --Formamos la ruta
         Ruta:=ASU.To_String(Get_DirectorioArchivos(Configuracion))  & Peticion.Uri.Path;
         --Y enviamos la cabecera
         Http_Common.EnviarCabecera(Ruta,Conexion,Peticion);

      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request del HEAD)");
         String'Write(conexion'access, CABECERA400_10 & Http_Common.End_Of_Header);
         --Cerramos la conexion forzosamente, por Bad Request
         FinConexion:=TRUE;

      end if;

   end Attend_HEAD_Petition;
----------------------------------------------------------------------------------------------------------


   procedure Attend_Petition_http10(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                                   Configuracion: in TInfoConfiguracion; FinConexion: out Boolean) is
   --Este procedimiento distribuye los metodos de tipo 1.0 de cada petición
   begin


      --De momento solo contempla los metodos GET y HEAD
      if Peticion.Method= Petition_Analysis.GET then
         Attend_GET_Petition(Peticion,Conexion,Configuracion,finConexion);
      elsif Peticion.Method= Petition_Analysis.HEAD then
         Attend_HEAD_Petition(Peticion,Conexion,Configuracion,finConexion);
      else
         String'Write(conexion'access, CABECERA501_10 & Http_Common.End_Of_Header);
         --Comprobamos por ultimo, si hay una cabecera que nos diga que tenemos que continuar
         Http_Common.ComprobarCierreConexion(Peticion,FinConexion);
         --FinConexion:=TRUE;
      end if;

   end Attend_Petition_Http10;

------------------------------------------------------------------------------------------------------


end http_10;
