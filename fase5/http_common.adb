
package body http_common is


   -----------------------------------------------------------------------------------------------
   --SUBPROGRAMAS AUXILIARES COMUNES
   -----------------------------------------------------------------------------------------------

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return boolean is
      --Le pasamos un campo, y un posible valor, y nos devuelve un booleano
      --diciendo si el valor es igual
      i: integer:=1;
      CampoEncontrado: boolean:= FALSE;
      IgualValor:Boolean:=FALSE;
   begin

      while i<=Peticion.Number_fields and (not CampoEncontrado) loop
        --Si lo encontramos, miramos si coincide el valor..
         if peticion.fields_Array.Fields(i).Name = Campo then
            CampoEncontrado:=TRUE;

            if Peticion.Fields_Array.Fields(i).Value=valor then
               IgualValor:=TRUE;
            end if;
         end if;
         i:=i+1;
      end loop;
          --Devolvemos el booleano que nos dice si el valor coincidi�.
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

--------------------------------------------------------------------------------------------
   function DameValorCampo(Peticion: in  Petition_Type;
                           Campo: in ASU.Unbounded_String) return ASU.Unbounded_String is

      --funcion auxiliar, que nos devuelve el valor de un campo dado en un unbounded
      I:Integer:=1;
      Encontrado: Boolean:=FALSE;
      ValorDevuelto: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
   begin

      while (I<=Peticion.Number_Fields) and (not Encontrado) loop
         if Peticion.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=TRUE;
            ValorDevuelto:=Peticion.Fields_Array.Fields(i).Value;
         end if;
            I:=i+1;
      end loop;

        return ValorDevuelto;

   end DameValorCampo;

   ---------------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------------------------
   function EsHostValido(Peticion: in Petition_Type;
                         Configuracion: in TInfoConfiguracion) return Boolean is
      --Comprueba la validez del host, dependiendo del tipo de peticion.
      --���DE MOMENTO SOLO MIRA EL DOMINIO POR DEFECTO!!!!
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

   -- SUBPROGRAMAS DE TRATAMIENTOS DE TIPO DE PETICIONES (COMUNES)
   -----------------------------------------------------------------
-----------------------------------------------------------------------------------------
   procedure EnviarArchivo(Ruta: in ASU.Unbounded_String;
                           Conexion: in out TCP.Connection;
                           Peticion: in Petition_Type;
                           FinConexion: in Boolean;
                           flagMaxConn: in Boolean) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura, y el envio del archivo.
      --Ademas controla las excepciones, enviando la cabecera 404 si el archivo no se encontr�.

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

         --Calculamos su tama�o, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));
         Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_line);
         end if;

         --Si hay que cerrar, agregamos el campo connection close
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access,"Connection: Close" & Http_Common.End_Of_Header_line);
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
               String'Write(conexion'access,CABECERA404_10);
            elsif Peticion.Version=Petition_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11);
            end if;

            --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
            if FinConexion or flagMaxConn then
               String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                            & "Connection: Close" & Http_Common.End_Of_Header);
            else
               String'Write(Conexion'Access, Http_Common.End_Of_Header);
            end if;
      end;

   end enviarArchivo;
   -------------------------------------------------------------------------------------------------------

   procedure EnviarCabecera (Ruta: in ASU.Unbounded_String;
                             Conexion: in out TCP.Connection;
                             Peticion: in Petition_Type;
                             FinConexion: in Boolean;
                             flagMaxConn: in Boolean) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura del fichero para calcular
      --su tama�o. Adem�s, si el fichero no existe, salta una excepcion y envia el mensaje por la conex.
      fichero: Ada.Streams.Stream_IO.File_Type;
      TamFichero: Natural;
   begin

      --Este bloque begin es para controlar si el fichero existe o no. Si no existe
      --levanta una excepcion de tipo Name_error que trataremos.
      begin
         --Mostramos la ruta
         Ada.Text_Io.Put_Line("Ruta del path: " & ASU.To_String(Ruta));
         SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));
         --Calculamos su tama�o, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));
         Ada.Text_Io.Put_Line("Abriendo el archivo, y enviandolo. Devolveremos 200");

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_Line);
         end if;

         --Si hay que cerrar, agregamos el campo connection close
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access,"Connection: Close" & Http_Common.End_Of_Header_line);
         end if;


         --Y el campo Content-length, que es com�n a ambas
         String'Write(conexion'access,"Content-Length: "& Natural'Image(TamFichero) & Http_Common.End_of_Header);
         SIO.Close(Fichero);

      exception
         when SIO.Name_Error =>
            -- DEVOLVER MENSAJE 404
            Ada.Text_Io.Put_Line("El fichero pedido no existe. Devolvemos 404");
            --De nuevo, la cabecera a devolver depende del tipo de peticion
            if Peticion.Version=Petition_Analysis.V10 then
               String'Write(conexion'access,CABECERA404_10);
            elsif Peticion.Version=Petition_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11);
            end if;

            --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
            if FinConexion or flagMaxConn then
               String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                            & "Connection: Close" & Http_Common.End_Of_Header);
            else
               String'Write(Conexion'Access, Http_Common.End_Of_Header);
            end if;


      end;
   end EnviarCabecera;

-------------------------------------------------------------------------------------------------
   procedure EnviarPost(Ruta: in out ASU.Unbounded_String;
                        Conexion: in out TCP.Connection;
                        Peticion: in out Petition_Type;
                        FinConexion: in Boolean;
                        flagMaxConn: in Boolean) is

      fichero: Ada.Streams.Stream_IO.File_Type;
      Res:Integer;
      Pipe1: Unix.T_Fildes_Ptr_Type := new Unix.T_Fildes;
      Pipe2: Unix.T_Fildes_Ptr_Type := new Unix.T_Fildes;
      Buffer: Unix.Buff_Ptr_Type := new String(1..1);
      Buffer_Length:Integer;
      Reply_buffer: Ada.Strings.Unbounded.Unbounded_String := ASU.Null_Unbounded_String;
      Unix_Call_Result:Integer;
      Tam_A_Leer:Integer:=0;
      Cad_Campo_Content_Length:ASU.Unbounded_String:= ASU.Null_Unbounded_string;
      Car_Leido: Character;
      Respuesta200Compuesta: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      TamContentLength: Natural:=0;

      -------------------------------------------------------------------------------------
      function CalcularContentLength (Buffer: in ASU.Unbounded_String) return Natural is
         TamDevuelto: Natural:=0;
         Pos:Integer;
      begin
         --HAY QUE CONTAR A PARTIR DE el end of header
         Pos:= ASU.Index(Buffer,(Http_Common.End_Of_header));
         --Aumentamos el valor de pos, para contar a partir de los siguientes
         Pos:=pos+3;

         TamDevuelto:=ASU.Length(Buffer)-Pos;

         Ada.Text_Io.Put_Line("EL TAMA�O DEL CONTENT-LENGTH QUE VAMOS A DEVOLVER ES: "
                              & Natural'Image(TamDevuelto));
         return TamDevuelto;
      end CalcularContentLength;
      ------------------------------------------------------------------------------------
begin

      --Creacion de los pipes
      res:= Unix.Pipe(Pipe1);
      res:= Unix.Pipe(Pipe2);

      --Primero, comprobamos si accede al directorio correcto
      if ASU.To_String(Peticion.Uri.Path)(1..9)="/cgi-bin/" then
         --Si se encuentra en cgi-bin, comprobaremos que tiene permisos de ejecucion

         --Este bloque begin es para controlar si el fichero existe o no. Si no existe
         --levanta una excepcion de tipo Name_error que trataremos.

         begin
            -------------INICIO DE BLOQUE DE TRATAMIENTO DE EXCEPCIONES--------------------------
            --Le agregamos el cgi-bin a la ruta
            Ada.Text_Io.Put_Line("RUTA AL ENTRAR AL TRAT POST: " & ASU.To_String(Ruta));

            --Intentamos abrirlo. Si no existe, saltar� la excepcion
            SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));

            --Comprobamos que tiene permisos de ejecucion
            Res:=Unix.Sys_Access(ASU.To_String(Ruta),Unix.X_OK);

            --Si la llamada devuelve 0, es que tiene permisos...
            if Res=0 then
               --Si tiene permisos...
               Ada.Text_io.Put_Line("Vamos a ejecutar el archivo...");
               Cad_Campo_Content_Length:= ASU.Null_Unbounded_String;
               --Leemos el resto de la peticion del cgi
               if ExisteCampo(Peticion,ASU.To_Unbounded_String("Content-Length")) then
                  --Calculamos hasta donde hay que leer
                  Cad_Campo_Content_Length:=DameValorCampo(Peticion,ASU.To_Unbounded_String("Content-Length"));

                  Tam_A_Leer:=Integer'Value(ASU.To_String(Cad_Campo_Content_Length));
                  Ada.Text_Io.Put_Line("Caracteres que tenemos que leer:" & Integer'Image(Tam_A_Leer));

                  --Inicializamos las misma cadena, y leemos
                  Peticion.Pet_Body:= ASU.Null_Unbounded_String;
                    for I in 1..Tam_A_Leer loop
                       Character'Read (conexion'Access, Car_leido);
                       Peticion.Pet_Body:= Peticion.Pet_Body & Car_Leido;
                    end loop;

               end if;

               --Fijamos las variables (despues de calcular los content length!!!!)
               res:= Unix.Setenv("CONTENT_LENGTH", Integer'Image(ASU.Length(Peticion.Pet_Body)));
               res:= Unix.Setenv("REQUEST_METHOD", "POST");

               Reply_Buffer:=ASU.Null_Unbounded_String;
               --DESVIO DE ENTRADA Y SALIDA ESTANDAR
               -- Executing the .cgi. Cgi_Bin_Path contains the path to the .cgi file, Pet_Body
               -- contains the petition body. Reply_Buffer will store the reply to send to the
               -- client.
               if Unix.Fork = 0 then
                  Unix_Call_Result := Unix.Close(Pipe1(1));
                  Unix_Call_Result := Unix.Close(Pipe2(0));
                  Unix_Call_Result := Unix.Close(0);
                  Unix_Call_Result := Unix.Dup(Pipe1(0));
                  Unix_Call_Result := Unix.Close(Pipe1(0));
                  Unix_Call_Result := Unix.Close(1);
                  Unix_Call_Result := Unix.Dup(Pipe2(1));
                  Unix_Call_Result := Unix.Close(Pipe2(1));
                  Unix_Call_Result := Unix.Execlp(Unbounded.To_String(ruta), Unbounded.To_String(ruta));
               else
                  Unix_Call_Result := Unix.Close(Pipe1(0));
                  Unix_Call_Result := Unix.Close(Pipe2(1));
                  Unix_Call_Result := Unix.Write(Pipe1(1), Unbounded.To_String(Peticion.Pet_Body), Unbounded.Length(Peticion.Pet_Body));
                  Unix_Call_Result := Unix.Close(Pipe1(1));
                  Buffer_Length := Unix.Read(Pipe2(0), Buffer, 1);
                  while Buffer_Length /= 0 loop
                     Reply_Buffer := Reply_Buffer & Buffer(1..Buffer_Length);
                     Buffer_Length := Unix.Read(Pipe2(0), Buffer, 1);
                  end loop;
                  -- Building reply message and sending to client..

                  --Enviamos la cabecera (depende de cada version)
                  if Peticion.Version=Petition_Analysis.V10 then
                     Respuesta200Compuesta:=Respuesta200Compuesta &
                       ASU.To_Unbounded_String(CABECERA200_10 & Http_Common.End_Of_Header_Line);

                  elsif Peticion.Version=Petition_Analysis.V11 then
                     Respuesta200Compuesta:=Respuesta200Compuesta &
                       ASU.To_Unbounded_String(CABECERA200_11 & Http_Common.End_Of_Header_Line);

                  end if;


                  --Si vamos a cerrar, le metemos una cabecera connection: close
                  if FinConexion or flagMaxConn then
                     Respuesta200Compuesta:= Respuesta200Compuesta &
                       ASU.To_Unbounded_String("Connection: Close" & Http_Common.End_Of_Header_Line);
                  end if;

                  Ada.Text_Io.Put_Line("Contenido de respuesta despues de concatenar cabecera : "
                                       &ASU.To_String(Respuesta200Compuesta));

                  --Calculamos el tama�o del contentlength
                  TamContentLength:=CalcularContentLength(Reply_Buffer);
                  --Lo concatenamos a nuestra respuesta
                  Respuesta200Compuesta:=Respuesta200Compuesta &
                    ASU.To_Unbounded_String(
                        "Content-Length: " & Natural'Image(TamContentLength)& Http_Common.End_Of_Header_line);

                  Ada.Text_Io.Put_Line("Contenido de respuesta despues de concatenar content Length: "
                                       &ASU.To_String(Respuesta200Compuesta));

                  --Le concantenamos el buffer de respuesta de ejecucion del programa...
                  Respuesta200Compuesta:=Respuesta200Compuesta & Reply_Buffer;
                  Ada.Text_Io.Put_Line("Contenido de respuesta despues de concatenar reply_buffer : "
                                       &ASU.To_String(Respuesta200Compuesta));

                  --Y ya lo podemos enviar
                  String'Write(Conexion'Access,ASU.To_String(Respuesta200Compuesta));

                  SIO.Close(Fichero);

               end if;




               --------------FIN DE TRATAMIENTO DE LOS PIPES-------------------------


            else--else de comprobracion de permisos

               --Si la llamada fue /=0, devolveremos un error de falta de permisos.Devolvemos403
               Ada.Text_Io.Put_Line("Accede a cgi-bin, pero el fichero no tiene permisos de ejecucion!!!");
               if Peticion.Version=Petition_Analysis.V10 then
                  String'Write(Conexion'Access,CABECERA403_10);
               elsif Peticion.Version=Petition_Analysis.V11 then
                  String'Write(Conexion'Access,CABECERA403_11);
               end if;

               --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
               if FinConexion or flagMaxConn then
                  String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                               & "Connection: Close" & Http_Common.End_Of_Header);
               else
                  String'Write(Conexion'Access, Http_Common.End_Of_Header);
               end if;

            end if;--end if de comprobacion de permisos




            --------------FIN DE BLOQUE DE TRATAMIENTO DE EXCEPCIONES ---------------------------
         exception
            when SIO.Name_Error =>
               -- DEVOLVER MENSAJE 404
               Ada.Text_Io.Put_Line("El archivo no existe. Devolvemos 404");
               --De nuevo, la cabecera a devolver depende del tipo de peticion
               if Peticion.Version=Petition_Analysis.V10 then
                  String'Write(conexion'access,CABECERA404_10);
               elsif Peticion.Version=Petition_Analysis.V11 then
                  String'Write(conexion'access,CABECERA404_11);
               end if;
               --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
               if FinConexion or flagMaxConn then
                  String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                               & "Connection: Close" & Http_Common.End_Of_Header);
               else
                  String'Write(Conexion'Access, Http_Common.End_Of_Header);
               end if;

         end;



      else --else de comprobar que cgi-bin
         --Si no, enviamos un forbidden
         Ada.Text_Io.Put_Line("No accede a /cgi-bin/, devolveremos un 403.");
         if Peticion.Version=Petition_Analysis.V10 then
            String'Write(Conexion'Access,CABECERA403_10);
         elsif Peticion.Version=Petition_Analysis.V11 then
            String'Write(Conexion'Access,CABECERA403_11);
         end if;

         --Si hay que cerrar, agregamos el connClose, si no...un fin de cabeceras
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                         & "Connection: Close" & Http_Common.End_Of_Header);
         else
            String'Write(Conexion'Access, Http_Common.End_Of_Header);
         end if;


      end if; --end if de ggi-bin

end EnviarPost;

end http_common;
