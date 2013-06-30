
package body http_common is

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return boolean is
      --Le pasamos un campo, y un posible valor, y nos devuelve un booleano
      --diciendo si el valor es igual
      i: integer:=1;
      CampoEncontrado: boolean:= FALSE;
      IgualValor:Boolean:=FALSE;
   begin

      --Recorremos todos los nombres de campo posible
      --Ada.Text_Io.Put_Line("Estamos buscando... Campo: " &ASU.To_String(Campo) &" Valor: " &ASU.To_String(Valor));


      while i<=Peticion.Number_fields and (not CampoEncontrado) loop
        --Si lo encontramos, miramos si coincide el valor..
         if peticion.fields_Array.Fields(i).Name = Campo then
            CampoEncontrado:=TRUE;
            --Ada.Text_Io.Put_Line("existe el campo");

            if Peticion.Fields_Array.Fields(i).Value=valor then
               IgualValor:=TRUE;
               --Ada.Text_Io.Put_Line("existe el campo, y coincide el valor");
            end if;
         end if;
         i:=i+1;
      end loop;
          --Devolvemos el booleano que nos dice si el valor coincidió.
      return IgualValor;
   end CoincideCampo;

-----------------------------------------------------------------------------------------
   function ExisteCampo(Peticion: in Petition_Type;
                        Campo: in ASU.Unbounded_String) return Boolean is
      --Funcion auxiliar, que nos dice si existe un campo en las cabeceras
          I: Integer:=1;
      Encontrado:Boolean:=FALSE;
   begin
      --Recorremos todos los posibles campos comparando...
      while (I<=Peticion.Number_Fields) and (not Encontrado) loop
         if Peticion.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=True;
         end if;
         I:=i+1;
      end loop;
      --Y devolvemos el booleano
      return Encontrado;
   end ExisteCampo;

-----------------------------------------------------------------------------------------
   procedure EnviarArchivo(Ruta: in ASU.Unbounded_String; Conexion: in out TCP.Connection;
                           Peticion: in Petition_Type) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura, y el envio del archivo.
      --Ademas controla las excepciones, enviando la cabecera 404 si el archivo no se encontró.

      fichero: Ada.Streams.Stream_IO.File_Type;
      Acceso_Fichero:   Ada.Streams.Stream_IO.Stream_Access;
      car_Leido:character;
      cadena_leida:ASU.Unbounded_string;
      TamFichero: Natural;

   begin

      --Este bloque begin es para controlar si el fichero existe o no. Si no existe
      --levanta una excepcion de tipo Name_error que trataremos.
      --Comprobamos por ultimo, si hay una cabecera que nos diga que tenemos que continuar
      begin
         --Mostramos la ruta
         Ada.Text_Io.Put_Line("Ruta del path: " & ASU.To_String(Ruta));
         SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));

         --Calculamos su tamaño, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));
         Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_Line);
         end if;


         --Y despues el campo Content-length, y el archivo(eso ya no depende de la version)
         String'Write(conexion'access,"Content-Length: "& Natural'Image(TamFichero) & Http_Common.End_of_Header);

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
            -- De nuevo, la cabecera depende del tio de peticion
            if Peticion.Version=Petition_Analysis.V10 then
               String'Write(conexion'access,CABECERA404_10 & Http_Common.End_Of_Header);
            elsif Peticion.Version=Petition_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11 & Http_Common.End_Of_Header);
            end if;
      end;

   end enviarArchivo;
   -------------------------------------------------------------------------------------------------------

   procedure EnviarCabecera (Ruta: in ASU.Unbounded_String; Conexion: in out TCP.Connection;
                             Peticion: in Petition_Type) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura del fichero para calcular
      --su tamaño. Además, si el fichero no existe, salta una excepcion y envia el mensaje por la conex.
      fichero: Ada.Streams.Stream_IO.File_Type;
      TamFichero: Natural;
   begin

      --Este bloque begin es para controlar si el fichero existe o no. Si no existe
      --levanta una excepcion de tipo Name_error que trataremos.
      begin
         --Mostramos la ruta
         Ada.Text_Io.Put_Line("Ruta del path: " & ASU.To_String(Ruta));
         SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));
         --Calculamos su tamaño, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));
         Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_Line);
         end if;

         --Y el campo Content-length, que es común a ambas
         String'Write(conexion'access,"Content-Length: "& Natural'Image(TamFichero) & Http_Common.End_of_Header);
         SIO.Close(Fichero);

      exception
         when SIO.Name_Error =>
            -- DEVOLVER MENSAJE 404
            Ada.Text_Io.Put_Line("El fichero pedido no existe. Devolvemos 404");
            --De nuevo, la cabecera a devolver depende del tipo de peticion
            if Peticion.Version=Petition_Analysis.V10 then
               String'Write(conexion'access,CABECERA404_10 & Http_Common.End_Of_Header);
            elsif Peticion.Version=Petition_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11 & Http_Common.End_Of_Header);
            end if;
      end;
   end EnviarCabecera;

   --------------------------------------------------------------------------------------------------------
   function EsHostValido(Peticion: in Petition_Type;
                         Configuracion: in TInfoConfiguracion) return Boolean is
      --Comprueba la validez del host, dependiendo del tipo de peticion.
      --¡¡¡DE MOMENTO SOLO MIRA EL DOMINIO POR DEFECTO!!!!
      EsValido:Boolean:=FALSE;
   begin

      --SI ES VERSION 1.0
      if Peticion.Version=Petition_Analysis.V10 then

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

      --SI ES VERSION 1.1...
      elsif Peticion.Version=Petition_Analysis.V11 then

         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Host")) then
            --Si no hay uri, miraremos en las cabeceras...
            if Peticion.Uri.Host=ASU.Null_Unbounded_String then
               --Y de momento en las cabeceras, solo mirarmos el de por defecto
               if CoincideCampo(Peticion,ASU.To_Unbounded_String("Host"),
                                Get_DominioPorDefecto(Configuracion)) then
                  --Si coincide con el de por defecto, es correcto..
                  EsValido:=TRUE;
               else
                  EsValido:=FALSE;
               end if;
            else
               --Si hay uri, prevalece el del URI. De momento solo comparamos con el default
               if ASU.To_String(Peticion.Uri.Host)= ASU.To_String(Get_DominioPorDefecto(Configuracion)) then
                  EsValido:=TRUE;
               else
                  EsValido:=FALSE;
               end if;
            end if;

         else
            --En 1.1, debe existir campo host.Si no,el programa que le llama enviara BadRequest
            EsValido:=FALSE;
         end if;


      end if;
      return EsValido;
   end EsHostValido;

   --------------------------------------------------------------------------------------------------------

   procedure ComprobarCierreConexion(Peticion:in Petition_Type; FinConexion:out Boolean) is
      --Inspecciona el campo connection, para variar o no el booleano global de cierre
   begin
      if Peticion.Version=Petition_Analysis.V10 then
         --En http1.0, seguiremos solo  si hay un campo Connection: Keep-Alive
         ---Como lo controlamos al principio, si ocurre un BR despues, lo cambiara
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection")) and
           CoincideCampo(Peticion,ASU.To_Unbounded_String("Connection"),
                         ASU.To_Unbounded_String("Keep-Alive")) then
            FinConexion:=FALSE;
            --Ada.Text_Io.Put_Line("CAMBIAMOS EL VALOR A FALSE, EN COMPROBARCERRARCONEX");
         else
            FinConexion:=TRUE;
            --Ada.Text_Io.Put_Line("CAMBIAMOS EL VALOR A TRUE, EN COMPROBARCERRARCONEX");
         end if;

      elsif Peticion.Version=Petition_Analysis.V11 then
         --En http1.1, seguimos a no ser que haya un campo Connection:Close
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection")) and
           CoincideCampo(Peticion,ASU.To_Unbounded_String("Connection"),
                         ASU.To_Unbounded_String("Close")) then
            FinConexion:=TRUE;
         --Ada.Text_Io.Put_Line("CAMBIAMOS EL VALOR A TRUE, EN COMPROBARCERRARCONEX");
         else
            FinConexion:=FALSE;
            --Ada.Text_Io.Put_Line("CAMBIAMOS EL VALOR A FALSE, EN COMPROBARCERRARCONEX");
         end if;
      end if;
   end ComprobarCierreConexion;
   ------------------------------------------------------------------------------------------

end http_common;
