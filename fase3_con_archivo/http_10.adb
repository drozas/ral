package body http_10 is

   function HostValido10(Peticion: in Petition_Type;
                        Configuracion:in tInfoConfiguracion) return Boolean is
   --funcion auxiliar que determina si es válido el host de 1.0
   --DE MOMENTO SOLO COMPRUEBA EL DOMINIO POR DEFECTO!!!!
      EsValido:Boolean:=FALSE;
   begin
        if ASU.To_String(Peticion.Uri.Host)= ASU.To_String(Get_DominioPorDefecto(Configuracion))  then
           --Si el host del uri es el nuestro, es correcto...
           EsValido:=TRUE;
        elsif Peticion.Uri.Host=ASU.Null_Unbounded_String then
           --Vemos si existe campo host...
           if ExisteCampo(Peticion,ASU.To_Unbounded_String("Host")) then
                          --Si hay campo host, y coincide, es valido..
                if CoincideCampo(peticion,ASU.To_Unbounded_String("Host"),
                                 Get_DominioPorDefecto(Configuracion)) then
                EsValido:=TRUE;
                else
                --si existe, pero no coincide, es falso...
                EsValido:=FALSE;
                end if;
            else
                --Si no existe, damos por hecho que es bueno...
                EsValido:=TRUE;
            end if;

        end if;

        return EsValido;
   end HostValido10;

-------------------------------------------------------------------------------------------------------

   procedure Attend_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                                        Configuracion: in tInfoConfiguracion) is
   --Este procedimiento distribuye los metodos de tipo 1.0 de cada petición

   begin

      --De momento solo contempla los metodos GET y HEAD
      if Peticion.Method= Petition_Analysis.GET then
         Attend_GET_Petition(Peticion,Conexion,configuracion);
      elsif Peticion.Method= Petition_Analysis.HEAD then
         Attend_HEAD_Petition(Peticion,Conexion,configuracion);
      else
         String'Write(conexion'access, CABECERA501);
      end if;

   end Attend_Petition;

------------------------------------------------------------------------------------------------------
   procedure Attend_GET_Petition(Peticion: in Petition_Type;
                Conexion: in out TCP.Connection; Configuracion: in tInfoConfiguracion) is
   -- Procedimiento que implementa el metodo GET de version 1.0
      fichero: Ada.Streams.Stream_IO.File_Type;
      Acceso_Fichero:   Ada.Streams.Stream_IO.Stream_Access;
      car_Leido:character;
      cadena_leida:ASU.Unbounded_string;
      TamFichero: Natural;
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.Put_Line("Atendiendo peticion GET de HTTP 1.0");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if HostValido10(Peticion,configuracion) then
                 --Este bloque begin es para controlar si el fichero existe o no. Si no existe
                 --levanta una excepcion de tipo Name_error que trataremos.
         begin
            --Formamos la ruta
                        Ruta:="webdocs/" & Peticion.Uri.Path;
            Ada.Text_Io.Put_Line("Ruta del path: " & ASU.To_String(Ruta));
            SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));

                        --Calculamos su tamaño, y preparamos la cabecera
            TamFichero := NATURAL(SIO.Size(fichero));
            Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");
            String'Write(conexion'Access, CABECERA200);
            String'Write(conexion'access,"Content-Length: "& Natural'Image(TamFichero) & End_of_Header);

                        --Accedemos al fichero
            Acceso_Fichero := SIO.Stream(Fichero);

                        --Lectura y escritura(envio) del fichero..
            while not SIO.End_Of_File(fichero) loop
               character'Read(acceso_fichero,car_leido);
               Cadena_Leida:=Cadena_Leida & Car_Leido;
            end loop;

            String'write(conexion'access, ASU.to_string(Cadena_Leida));

            SIO.Close(Fichero);
         exception
            when SIO.Name_Error =>
               -- DEVOLVER MENSAJE 404
               Ada.Text_Io.Put_Line("El fichero pedido no existe. Devolvemos 404");
               String'Write(conexion'access,CABECERA404);
         end;

      else
         --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request de GET)");
         String'Write(conexion'access, CABECERA400);

      end if;

   end Attend_GET_Petition;

---------------------------------------------------------------------------------------------------------

procedure Attend_HEAD_Petition(Peticion: in Petition_Type; Conexion: in out TCP.Connection;
                              Configuracion: in tInfoConfiguracion) is
      fichero: Ada.Streams.Stream_IO.File_Type;
      TamFichero: Natural;
      Ruta: ASU.Unbounded_String;
   begin

      Ada.Text_Io.PUt_Line("Atendiendo el get...");
      --Comprobacion del dominio (de momento sin acceso a ficheros)
      if HostValido10(Peticion,configuracion) then
                 --Este bloque begin es para controlar si el fichero existe o no. Si no existe
                 --levanta una excepcion de tipo Name_error que trataremos.
         begin
            --Formamos la ruta
                        Ruta:="webdocs/" & Peticion.Uri.Path;
            Ada.Text_Io.Put_Line("Ruta del path: " & ASU.To_String(Ruta));
            SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));
            --Calculamos su tamaño, y preparamos la cabecera
            TamFichero := NATURAL(SIO.Size(fichero));
            Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");
            String'Write(conexion'Access, CABECERA200);
            String'Write(conexion'access,"Content-Length: "& Natural'Image(TamFichero) & End_of_Header);
            SIO.Close(Fichero);

         exception
            when SIO.Name_Error =>
               -- DEVOLVER MENSAJE 404
               Ada.Text_Io.Put_Line("El fichero pedido no existe. Devolvemos 404");
               String'Write(conexion'access,CABECERA404);
         end;

      else
             --Si el host no es válido, devolvemos un error 400
         Ada.Text_Io.Put_Line("Host inválido. Devolveremos 400 (bad request del HEAD)");
         String'Write(conexion'access, CABECERA400);

      end if;

   end Attend_HEAD_Petition;
----------------------------------------------------------------------------------------------------------


end http_10;
