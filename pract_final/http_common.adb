-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: http_common
-- David Rozas Domingo
-- ------------------------------------------------------------

package body http_common is

   -------------------------------------------------------------------------------------------------------
   procedure LeerCabecera(Conexion: in out TCP.Connection;
                          CadenaDevuelta: out ASU.Unbounded_String) is
      --Lee la cabecera de la conexión
      A_Char: Character;
      LF_Found: Boolean;
   begin
      --Inicializamos las variables
      CadenaDevuelta:= ASU.Null_Unbounded_String;
      LF_Found:= False;

      -- Leemos caracter a caracter hasta encontrar dos End_of_header_line (CRLF+CRLF)
      loop
         Character'Read (Conexion'Access, A_Char);
         CadenaDevuelta:=CadenaDevuelta & A_Char;
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
   end LeerCabecera;

-----------------------------------------------------------------------------------
   procedure esDominioServido(Host:in out  Asu.Unbounded_String;
                              Configuracion: in TInfoConfiguracion;
                              EsServido: out boolean) is
      --Comprueba si el host es parte de nuestros dominios servidos
      Domain_Con_port: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      I:Integer;
     begin
        I:=1;
        EsServido:=False;
        --Recorremos, hasta fin de bucle o encontrarlo
        while (I<=Configuracion.NTotalDominios) and ( not esServido) loop

           Domain_Con_Port:=ASU.Null_Unbounded_String;
           Domain_Con_Port:= ASU.To_Unbounded_String( ASU.To_String(Configuracion.Dominios(I))
                                                      & ":" &
                                                      ASU.To_String(Get_Puerto(Configuracion)));

           if Configuracion.Dominios(I)= Host then
              --Si lo encontramos sin port, simplemente cambiamos el booleano
              esServido:= True;
           elsif Domain_Con_Port= Host then
              --Si lo encontramos con port, devolveremos el valor de host sin el port; ya que si no no encuentra
              --la carpeta www.localdomain2.org:XXXX
              EsServido:= True;
              Host:= Configuracion.Dominios(I);
           end if;
           I:=i+1;
        end loop;

     end EsDominioServido;
   --------------------------------------------------------------------------------------------------------
   function EsHostLocalValido(Peticion: in Petition_Type;
                               Configuracion: in TInfoConfiguracion) return ASU.Unbounded_String is
      --Comprueba la validez del host, dependiendo de la version y devuelve el host en un unbounded.
      --Si el host no es válido, devolverá la cadena vacía
      ValorCampoHost: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      ValorURIHost: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      Ip_Con_Port: ASU.Unbounded_String;
      HostDevuelto: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      EsServido: Boolean:= False;
      ValorURIHost_Con_Port: ASU.Unbounded_String;
      Port_uri:ASU.Unbounded_String;
   begin
      --Recogemos los valores que mas vamos a usar
      Ip_Con_port:=  ASU.To_Unbounded_String( ASU.To_String(Get_IpMaquina(Configuracion))
                                              & ":" &
                                              ASU.To_String(Get_Puerto(Configuracion)));

      ValorURIHost:= Peticion.Uri.Host;
      --le recortamos al port de la uri el espacio en blanco que nos mete al transformar
      Port_uri:= ASU.To_Unbounded_String(Natural'Image(Peticion.Uri.Port));
      Port_Uri:=ASU.To_Unbounded_String(ASU.To_String(Port_Uri)(2..ASU.Length(Port_uri)));
      ValorURIHost_Con_Port:= ASU.To_Unbounded_String( ASU.To_String(Peticion.Uri.Host)
                                                       & ":" &
                                                       ASU.To_String(Port_Uri));

      --SI ES VERSION 1.0
      if Peticion.Version=Petition_Reply_Analysis.V10 then

         if ValorURIHost/=ASU.Null_Unbounded_String then
            --Si el uri no esta vacio
            --Lo validamos solo si es local
            EsDominioServido(ValorURIHost,Configuracion,EsServido);
            if EsServido  then
               --Hay uri, y lo servimos. Lo devolvemos.
               HostDevuelto:= ValorURIHost;
            elsif ValorURIHost=ASU.To_String(Get_IpMaquina(Configuracion))
              or ValorURIHost_Con_Port=Ip_Con_Port then
               --Hay uri, y es ip o ip con puerto. Devolvemos el host por defecto
               HostDevuelto:= Get_DominioPorDefecto(Configuracion);
            else
               --Hay uri, pero no lo servimos. Devolvemos cadena vacía.
               HostDevuelto:= ASU.Null_Unbounded_String;
            end if;

         elsif ExisteCampo(Peticion,ASU.To_Unbounded_String("Host")) then
            --Si noy hay uri, pero hay campo host; es obligatorio que sea uno de los servidos
            ValorCampoHost:= DameValorCampo(Peticion,ASU.To_Unbounded_String("Host"));
            EsDominioServido(ValorCampoHost,Configuracion,EsServido);
            if EsServido then
               --Hay host, y lo servimos. Lo devolvemos tal cual.
               HostDevuelto:= ValorCampoHost;

            elsif ValorCampoHost=Get_IpMaquina(Configuracion)
              or ValorCampoHost=Ip_Con_Port
              or ValorCampoHost=ASU.Null_Unbounded_String then
               --Hay host, y es ip; o ip + puerto o vacio. Devolvemos el de por defecto
               HostDevuelto:= Get_DominioPorDefecto(Configuracion);
            else
               --Ni lo servimos, ni es nuestra ip. Devolvemos cadena vacia.
               HostDevuelto:=ASU.Null_Unbounded_String;


            end if;
         else
            --Ni en la uri, ni en el host. Devolvemos el de por defecto.
            HostDevuelto:= Get_DominioPorDefecto(Configuracion);

         end if;


      --SI ES VERSION 1.1...
      elsif Peticion.Version=Petition_Reply_Analysis.V11 then

         -- en 1.1 debe existir campo Host!
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Host")) then
            --si existe campo host..
            ValorCampoHost:=DameValorCampo(Peticion,ASU.To_Unbounded_String("Host"));

            if ValorURIHost/=ASU.Null_Unbounded_String then
               --Si hay algun valor en el uri
               EsDominioServido(ValorURIHost,Configuracion,EsServido);
               if EsServido then
                  --Hay host, hay uri; y lo servimos. Lo devolvemos.
                  HostDevuelto:=ValorURIHost;

               elsif ValorURIHost=ASU.To_String(Get_IpMaquina(Configuracion))
                 or ValorURIHost_Con_Port=Ip_Con_Port then
                  -- hay uri, y es ip o ip+port. Devolvemos el de por defecto.
                  HostDevuelto:= Get_DominioPorDefecto(Configuracion);

               else
                  --Hay host, hay uri; pero no lo servimos. Devolvemos cadena vacia.
                  HostDevuelto:= ASU.Null_Unbounded_String;

               end if;
            else
               --Si la uri esta vacia, miramos solo el host( es 1.1, tiene que estar)
               EsDominioServido(ValorCampoHost,Configuracion,EsServido);
               if EsServido then
                  --No uri; pero hay host y lo servimos. Asi que lo devolvemos tal cual.
                  HostDevuelto:= ValorCampoHost;

               elsif ValorCampoHost=Get_IpMaquina(Configuracion)
                 or ValorCampoHost=Ip_Con_Port then
                  --No uri. Hay host y es ip o ip+port. Devolvemos el de por defecto.
                 HostDevuelto:= Get_DominioPorDefecto(Configuracion);

               else
                  --No uri. Hay host; pero no lo servimos. Devolvemos cadena nula.
                  HostDevuelto:= ASU.Null_Unbounded_String;

               end if;
            end if;

         else
            --Si no hay campo host; ni si quiera hay que mirar el uri. Devolvemos cadena vacia.
            HostDevuelto:= ASU.Null_Unbounded_String;

         end if;

      end if;

      return HostDevuelto;
   end EsHostLocalValido;

-----------------------------------------------------------------------------------------------------------
   function EsHostRemotoValido(Peticion: in Petition_Type ) return ASU.Unbounded_String is

      --Devuelve el host con el que trabajaremos, y veremos si es invalido si devuelve la cadena vacia
      HostDevuelto: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
   begin

      if Peticion.Uri.Host/= ASU.Null_Unbounded_String then
         --si existe uri.host
         HostDevuelto:= Peticion.Uri.Host;
      else
         HostDevuelto:= ASU.Null_Unbounded_String;
      end if;
      return HostDevuelto;
   end EsHostRemotoValido;
   --------------------------------------------------------------------------------------------------------

   procedure ComprobarCierreConexion(Peticion:in Petition_Type; FinConexion:out Boolean) is
      --Inspecciona el campo connection, para variar o no el booleano global de cierre
   begin
      if Peticion.Version=Petition_Reply_Analysis.V10 then
         --En http1.0, seguiremos solo  si hay un campo Connection: Keep-Alive
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection")) and
           CoincideCampo(Peticion,ASU.To_Unbounded_String("Connection"),
                         ASU.To_Unbounded_String("Keep-Alive")) then
            FinConexion:=FALSE;
         else
            FinConexion:=TRUE;
         end if;

      elsif Peticion.Version=Petition_Reply_Analysis.V11 then
         --En http1.1, seguimos a no ser que haya un campo Connection:Close
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection")) and
           CoincideCampo(Peticion,ASU.To_Unbounded_String("Connection"),
                         ASU.To_Unbounded_String("Close")) then
            FinConexion:=TRUE;
         else
            FinConexion:=FALSE;
         end if;
      end if;
   end ComprobarCierreConexion;
   --------------------------------------------------------------------------------------------------------

   procedure ComprobarCierreConexionEnRemota(Peticion:in Petition_Type; FinConexion:out Boolean) is
      --Inspecciona el campo Connection y Proxy-Connection, para variar o no el booleano global de cierre en el cliente.
      ValorCabeceraAux: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
   begin
      if Peticion.Version=Petition_Reply_Analysis.V10 then
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Proxy-Connection")) then
            ValorCabeceraAux:= DameValorCampo(Peticion,ASU.To_Unbounded_String("Proxy-Connection"));
            if ASU.To_String(ValorCabeceraAux)="Keep-Alive" then
               FinConexion:= False;
            else
               FinConexion:=True;
            end if;
         elsif ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection")) then
            ValorCabeceraAux:= DameValorCampo(Peticion,ASU.To_Unbounded_String("Connection"));
            if ASU.To_String(ValorCabeceraAux)="Keep-Alive" then
               FinConexion:= False;
            else
               FinConexion:= True;
            end if;
         else
            FinConexion:= True;
         end if;

      elsif Peticion.Version=Petition_Reply_Analysis.V11 then
         --En http1.1, seguimos a no ser que haya un campo Connection:Close o Proxy-Connection:Close (que prevalece)
         if ExisteCampo(Peticion,ASU.To_Unbounded_String("Proxy-Connection")) then
            ValorCabeceraAux:= DameValorCampo(Peticion, ASU.To_Unbounded_String("Proxy-Connection"));
            if ASU.To_String(ValorCabeceraAux)="Close" then
               FinConexion:= true;
            else
               FinConexion:= false;
            end if;
         elsif ExisteCampo(Peticion,ASU.To_Unbounded_String("Connection") ) then
            ValorCabeceraAux:= DameValorCampo(Peticion, ASU.To_Unbounded_String("Connection"));
            if ASU.To_String(ValorCabeceraAux)="Close" then
               FinConexion:=true;
            else
               FinConexion:= false;
            end if;
         else
            FinConexion:=False;
         end if;
      end if;
   end ComprobarCierreConexionEnRemota;
   ------------------------------------------------------------------------------------------



   -- SUBPROGRAMAS DE TRATAMIENTOS DE METODOS PARA PETICIONES LOCALES
   -------------------------------------------------------------------
   -----------------------------------------------------------------------------------------
   procedure EnviarArchivo(Ruta: in ASU.Unbounded_String;
                           Conexion: in out TCP.Connection;
                           Peticion: in Petition_Type;
                           FinConexion: in Boolean;
                           flagMaxConn: in Boolean) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura, y el envio del archivo.
      --Ademas controla las excepciones, enviando la cabecera 404 si el archivo no se encontró.

      fichero: Ada.Streams.Stream_IO.File_Type;
      Acceso_Fichero:   Ada.Streams.Stream_IO.Stream_Access;
      car_Leido:character;
      cadena_leida:ASU.Unbounded_string;
      TamFichero: Natural;

   begin

      --Este bloque begin es para controlar si el fichero existe o no mediante excepcion Name_error.
      begin
         --Abrimos el fichero en modo lectura.
         SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));

         --Calculamos su tamaño, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Reply_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Reply_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_line);
         end if;

         --Si hay que cerrar, agregamos el campo connection close
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access,"Connection: Close" & Http_Common.End_Of_Header_line);
         end if;


         --Y despues el campo Content-length, y el archivo(eso ya no depende de la version)
         String'Write(conexion'access,"Content-Length:"& Natural'Image(TamFichero) & Http_Common.End_of_Header);

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
            -- Si el fichero no existe; devolveremos un 404

            --De nuevo, la primera linea a devolver depende del tipo de peticion
            if Peticion.Version=Petition_Reply_Analysis.V10 then
               String'Write(conexion'access,CABECERA404_10 & Http_Common.End_Of_Header_line);
            elsif Peticion.Version=Petition_Reply_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11 & Http_Common.End_Of_Header_line);
            end if;
            String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG404));
            --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
            if FinConexion or flagMaxConn then
              String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                            & "Connection: Close" & Http_Common.End_Of_Header);
            else
               String'Write(Conexion'Access, Http_Common.End_Of_Header);
            end if;
            String'Write(Conexion'Access, PAG404);

      end;

   end enviarArchivo;
   -------------------------------------------------------------------------------------------------------

   procedure EnviarCabecera (Ruta: in ASU.Unbounded_String;
                             Conexion: in out TCP.Connection;
                             Peticion: in Petition_Type;
                             FinConexion: in Boolean;
                             flagMaxConn: in Boolean) is
      --Recibe una ruta, y la conexion. Se encarga de gestionar la apertura del fichero para calcular
      --su tamaño. Además, si el fichero no existe, salta una excepcion y envia el mensaje por la conex.
      fichero: Ada.Streams.Stream_IO.File_Type;
      TamFichero: Natural;
   begin

      --Este bloque begin es para controlar si el fichero existe o no. Si no existe
      --levanta una excepcion de tipo Name_error que trataremos.
      begin
         --Abrimos el fichero en modo lectura.
         SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));
         --Calculamos su tamaño, y preparamos la cabecera
         TamFichero := NATURAL(SIO.Size(fichero));

         --Escribimos la cabecera (depende de cada version)
         if Peticion.Version=Petition_Reply_Analysis.V10 then
            String'Write(conexion'Access, CABECERA200_10 & Http_Common.End_Of_Header_Line);
         elsif Peticion.Version=Petition_Reply_Analysis.V11 then
            String'Write(conexion'Access, CABECERA200_11 & Http_Common.End_Of_Header_Line);
         end if;

         --Si hay que cerrar, agregamos el campo connection close
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access,"Connection: Close" & Http_Common.End_Of_Header_line);
         end if;


         --Y el campo Content-length, que es común a ambas
         String'Write(conexion'access,"Content-Length:"& Natural'Image(TamFichero) & Http_Common.End_of_Header);
         SIO.Close(Fichero);

      exception
         when SIO.Name_Error =>
            -- Si el fichero no existe, enviaremos un 404

            --De nuevo, la cabecera a devolver depende del tipo de peticion
            if Peticion.Version=Petition_Reply_Analysis.V10 then
               String'Write(conexion'access,CABECERA404_10 & Http_Common.End_Of_Header_line);
            elsif Peticion.Version=Petition_Reply_Analysis.V11 then
               String'Write(conexion'access,CABECERA404_11 & Http_Common.End_Of_Header_line);
            end if;
            String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG404));
            --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
            if FinConexion or flagMaxConn then
              String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                            & "Connection: Close" & Http_Common.End_Of_Header);
            else
               String'Write(Conexion'Access, Http_Common.End_Of_Header);
            end if;
            String'Write(Conexion'Access, PAG404);
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
         --Calcula el tamaño del valor para el Content-Length del resultado de la ejecucion
         --del POST
         TamDevuelto: Natural:=0;
         Pos:Integer;
      begin
         --Buscamos el end_of_header
         Pos:= ASU.Index(Buffer,(Http_Common.End_Of_header));
         --Aumentamos el valor de pos, para contar a partir de los siguientes
         Pos:=pos+3;

         TamDevuelto:=ASU.Length(Buffer)-Pos;

         return TamDevuelto;
      end CalcularContentLength;
      ------------------------------------------------------------------------------------
begin

      --Creacion de los pipes
      res:= Unix.Pipe(Pipe1);
      res:= Unix.Pipe(Pipe2);

      --Leemos el resto de la peticion, a partir del valor del Content-Length
      Cad_Campo_Content_Length:= ASU.Null_Unbounded_String;

      if ExisteCampo(Peticion,ASU.To_Unbounded_String("Content-Length")) then
         --Calculamos hasta donde hay que leer
         Cad_Campo_Content_Length:=DameValorCampo(Peticion,ASU.To_Unbounded_String("Content-Length"));
         Tam_A_Leer:=Integer'Value(ASU.To_String(Cad_Campo_Content_Length));

         --Inicializamos las misma cadena, y leemos
         Peticion.Pet_Body:= ASU.Null_Unbounded_String;
         for I in 1..Tam_A_Leer loop
            Character'Read (conexion'Access, Car_leido);
            Peticion.Pet_Body:= Peticion.Pet_Body & Car_Leido;
         end loop;

      end if;

      --Primero, comprobamos si accede al directorio correcto
      if ASU.To_String(Peticion.Uri.Path)(1..9)="/cgi-bin/" then
         --Si se encuentra en cgi-bin, comprobaremos que tiene permisos de ejecucion

         --Este bloque begin es para controlar si el fichero existe o no. Si no existe
         --levanta una excepcion de tipo Name_error que trataremos.

         begin
            -------------INICIO DE BLOQUE DE TRATAMIENTO DE EXCEPCIONES--------------------------

            --Intentamos abrirlo. Si no existe, saltará la excepcion
            SIO.Open(Fichero, SIO.In_File, ASU.To_String(Ruta));

            --Comprobamos que tiene permisos de ejecucion
            Res:=Unix.Sys_Access(ASU.To_String(Ruta),Unix.X_OK);

            --Si la llamada devuelve 0, es que tiene permisos...
            if Res=0 then
               --Fijamos las variables (despues de calcular los content length!!!!)
               res:= Unix.Setenv("CONTENT_LENGTH", Integer'Image(ASU.Length(Peticion.Pet_Body)));
               res:= Unix.Setenv("REQUEST_METHOD", "POST");

               Reply_Buffer:=ASU.Null_Unbounded_String;
               --DESVIO DE ENTRADA Y SALIDA ESTANDAR
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


                  --Enviamos la cabecera (depende de cada version)
                  if Peticion.Version=Petition_Reply_Analysis.V10 then
                     Respuesta200Compuesta:=Respuesta200Compuesta &
                       ASU.To_Unbounded_String(CABECERA200_10 & Http_Common.End_Of_Header_Line);

                  elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                     Respuesta200Compuesta:=Respuesta200Compuesta &
                       ASU.To_Unbounded_String(CABECERA200_11 & Http_Common.End_Of_Header_Line);

                  end if;

                  --Si vamos a cerrar, le metemos una cabecera connection: close
                  if FinConexion or flagMaxConn then
                     Respuesta200Compuesta:= Respuesta200Compuesta &
                       ASU.To_Unbounded_String("Connection: Close" & Http_Common.End_Of_Header_Line);
                  end if;

                  --Calculamos el tamaño del contentlength
                  TamContentLength:=CalcularContentLength(Reply_Buffer);
                  --Lo concatenamos a nuestra respuesta
                  Respuesta200Compuesta:=Respuesta200Compuesta &
                    ASU.To_Unbounded_String("Content-Length: " & Natural'Image(TamContentLength)& Http_Common.End_Of_Header_line);
                  --Le concantenamos el buffer de respuesta de ejecucion del programa...
                  Respuesta200Compuesta:=Respuesta200Compuesta & Reply_Buffer;
                  --Y ya lo podemos enviar
                  String'Write(Conexion'Access,ASU.To_String(Respuesta200Compuesta));

                  SIO.Close(Fichero);

               end if;

            else--else de comprobracion de permisos

               --Si la llamada fue /=0, devolveremos un error de falta de permisos.Devolvemos403

               --Devolvemos una pag. web que explica el error a navegadores
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(Conexion'Access,CABECERA403_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(Conexion'Access,CABECERA403_11 & Http_Common.End_Of_Header_line);
               end if;

               -- Asi que, tenemos que agregar un Content-Length
               String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG403));

               --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
               if FinConexion or flagMaxConn then
                  String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                               & "Connection: Close" & Http_Common.End_Of_Header);
               else
                    String'Write(Conexion'Access, Http_Common.End_Of_Header);
               end if;

               String'Write(Conexion'Access,PAG403);

            end if;

            --------------FIN DE BLOQUE DE TRATAMIENTO DE EXCEPCIONES ---------------------------
         exception
            when SIO.Name_Error =>
               --Si el fichero no existe, devolveremos un 404; junto a una pag html explicando el error.

               --De nuevo, la cabecera a devolver depende del tipo de peticion
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(conexion'access,CABECERA404_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(conexion'access,CABECERA404_11 & Http_Common.End_Of_Header_line);
               end if;

               --Cabecera Content-Length; con el tamaño de la pagina de error.
               String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG404));
               --Si hay que cerrar, agregamos el Connection:Close, si no...un fin de cabeceras
               if FinConexion or flagMaxConn then
                  String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                            & "Connection: Close" & Http_Common.End_Of_Header);
               else
                  String'Write(Conexion'Access, Http_Common.End_Of_Header);
               end if;
               String'Write(Conexion'Access, PAG404);
         end;



      else --else de comprobar que el directorio es cgi-bin
         --Si no, enviamos un 403; junto a una pag.web explicando el error


         if Peticion.Version=Petition_Reply_Analysis.V10 then
            String'Write(Conexion'Access,CABECERA403_10 & Http_Common.End_Of_Header_line);
         elsif Peticion.Version=Petition_Reply_Analysis.V11 then
            String'Write(Conexion'Access,CABECERA403_11 & Http_Common.End_Of_Header_line);
         end if;

         --Content-Length con tamaño de la pag.web
         String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG403));
         --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                         & "Connection: Close" & Http_Common.End_Of_Header);
         else
            String'Write(Conexion'Access, Http_Common.End_Of_Header);
         end if;

         String'Write(Conexion'Access,PAG403);

      end if;

end EnviarPost;

end http_common;
