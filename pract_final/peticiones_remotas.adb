-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: petitciones_remotas
-- David Rozas Domingo
-- ------------------------------------------------------------

package body Peticiones_Remotas is

   procedure Attend_Remote_Petition (Peticion: in out Petition_Type;
                                     Conexion: in out TCP.Connection;
                                     HostDevuelto: in ASU.Unbounded_String;
                                     FinConexion: in out Boolean;
                                     flagMaxConn: in Boolean) is
      Ip_Remota: ASU.Unbounded_String;
      Puerto_Remoto: Natural;
      Serv_EP: TCP.End_Point;
      ConexionRemota: aliased TCP.Connection;
      PeticionRemota: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      CabeceraRespRemota: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      RespuestaRemota_ReplyType: Petition_Reply_Analysis.Reply_Type;
      A_Char: Character;
      RespuestaAlCliente:ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      TamBody: Integer:=0;
      ValorCampoAux: ASU.Unbounded_String:= ASU.Null_Unbounded_String;

   begin
      begin
      --Sacamos la ip del servidor remoto a partir de su dns; y su puerto lo obtenemos del uri
      Ip_Remota:= ASU.To_Unbounded_String(Lower_Layer.Inet.Misc.To_IP(ASU.To_String(HostDevuelto)));
      Puerto_Remoto:= Peticion.Uri.Port;

      Ada.Text_Io.Put_Line("Construyendo end point con : " & ASU.To_String(HostDevuelto));
      Ada.Text_Io.Put_Line("Ip : " &  Asu.To_String(Ip_Remota) & " . Puerto: " & Integer'Image(Puerto_Remoto));
      --Creamos el E.P, con su ip, en el puerto 80, y nos ponemos a escuchar
      Serv_EP := TCP.Build (ASU.To_String(Ip_Remota),Puerto_Remoto);
      --Iniciamos la conexión  en ese end_point
      TCP.Connect (Serv_EP, ConexionRemota);

      --Comprobamos si hay que cerrar la conexion con el cliente por cabeceras Proxy-Connection o Connection-Close
      --AUNQUE MODIFIQUEMOS LA PETICION MÁS ADELANTE...AQUÍ YA HEMOS GUARDADO LO QUE HAY QUE HACER EN EL BOOLEANO
      Http_Common.ComprobarCierreConexionEnRemota(Peticion,FinConexion);


      --########## FILTRADO DE CAMPOS DE PETICION AL SERVIDOR REMOTO #####################

      ValorCampoAux:= DameValorCampo(Peticion,ASU.To_Unbounded_String("Connection"));
      --Eliminamos el campo cuyo nombre aparece en Connection (close, keep-alive)
      if ValorCampoAux/= ASU.Null_Unbounded_String then
         Petition_Reply_Analysis.Remove_Field(Peticion.Fields_Array,ASU.To_String(ValorCampoAux));
      end if;

      --Eliminamos el campo Connection
      Petition_Reply_Analysis.Remove_Field(Peticion.Fields_Array,"Connection");

      -- Igualmente, eliminamos el campo cuyo nombre aparece en Connection (close, keep-alive)
      ValorCampoAux:= DameValorCampo(Peticion,ASU.To_Unbounded_String("Proxy-Connection"));
      if ValorCampoAux/= ASU.Null_Unbounded_String then
         Petition_Reply_Analysis.Remove_Field(Peticion.Fields_Array,ASU.To_String(ValorCampoAux));
      end if;

      --Eliminamos el campo Proxy-Connection
      Petition_Reply_Analysis.Remove_Field(Peticion.Fields_Array,"Proxy-Connection");

      --######################################################################


      -- ############# ENVIO DE PETICION REMOTA ################################
      PeticionRemota:= Petition_Reply_Analysis.Build_Petition(Peticion);
      String'Write(ConexionRemota'Access,ASU.To_String(PeticionRemota));
      --########################################################################


      --####### RECOGIDA DE RESPUESTA REMOTA ################################

      -- Lectura de la cabecera
      Http_Common.LeerCabecera(ConexionRemota,CabeceraRespRemota);
      --Esa cabecera, la analizamos con el Analize_Reply
      Petition_Reply_Analysis.Analyze_Reply(CabeceraRespRemota,RespuestaRemota_ReplyType);

      --Y ahora con la cabecera analizada, tenemos que escribir el cuerpo
      TamBody:=0;

      --Si hay cabecera content-Length, sacamos su valor, y lo escribimos hasta donde nos indica
      if ExisteCampoResp(RespuestaRemota_ReplyType, ASU.To_Unbounded_String("Content-Length")) then
         TamBody:= Integer'Value(ASU.To_String(DameValorCampoResp(RespuestaRemota_ReplyType,
                                                                  ASU.To_Unbounded_String("Content-Length"))));

         for I in 1..TamBody loop
            Character'Read(ConexionRemota'Access,A_Char);
            RespuestaRemota_ReplyType.Reply_Body:= RespuestaRemota_ReplyType.Reply_Body & A_Char;
         end loop;
      else
         --Si no hay cabecera content-length, leeremos hasta que salte la excepcion

         loop
            begin
               Character'Read(ConexionRemota'Access,A_Char);
               RespuestaRemota_ReplyType.Reply_Body:= RespuestaRemota_ReplyType.Reply_Body & A_Char;
            exception
               --Cuando salte la excepcion de fin de fichero, forzamos la salida del bucle
               when Ada.Io_Exceptions.End_Error=>exit;
            end;
         end loop;
      end if;


      --Ahora, ya podemos cerrar la conexion con el servidor remoto
      TCP.Dispose(ConexionRemota);
      --##################################################################################



      --########## FILTRADO DE CAMPOS DE RESPUESTA AL CLIENTE  #####################

      --Eliminamos el campo cuyo nombre aparece en Connection (close, keep-alive)
      Petition_Reply_Analysis.Remove_Field(RespuestaRemota_ReplyType.Fields_Array,
                                           ASU.To_String(DameValorCampoResp(RespuestaRemota_ReplyType,
                                                                            ASU.To_Unbounded_String("Connection"))));

      --Eliminamos el campo Connection
      Petition_Reply_Analysis.Remove_Field(RespuestaRemota_ReplyType.Fields_Array,"Connection");


      --Eliminamos el campo cuyo nombre aparece en Proxy-Connection (close, keep-alive)
      Petition_Reply_Analysis.Remove_Field(RespuestaRemota_ReplyType.Fields_Array,
                                           ASU.To_String(DameValorCampoResp(RespuestaRemota_ReplyType,
                                                                            ASU.To_Unbounded_String("Proxy-Connection"))));

      --Eliminamos el campo Proxy-Connection
      Petition_Reply_Analysis.Remove_Field(RespuestaRemota_ReplyType.Fields_Array,"Proxy-Connection");

      --######################################################################


      --##################ENVIO DE RESPUESTA AL CLIENTE ##########################
      --Llamamos a la funcion que construye un unbounded a partir del tipo reply
      RespuestaAlCliente:= Build_Reply(RespuestaRemota_ReplyType,FinConexion,flagMaxConn);
      --Y ya le enviamos la respuesta
      String'Write(Conexion'access,ASU.To_String(RespuestaAlCliente));
      --########################################################################


      exception
         when Ada_Sockets.Host_Name_Not_Found =>
            -- Si la respuesta del servidor remoto es invalida, enviamos un 504

            --De nuevo, la primera linea a devolver depende del tipo de peticion
            if Peticion.Version=Petition_Reply_Analysis.V10 then
               String'Write(conexion'access,CABECERA504_10 & Http_Common.End_Of_Header_line);
            elsif Peticion.Version=Petition_Reply_Analysis.V11 then
               String'Write(conexion'access,CABECERA504_11 & Http_Common.End_Of_Header_line);
            end if;
         String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG504));
         --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
         if FinConexion or flagMaxConn then
            String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                         & "Connection: Close" & Http_Common.End_Of_Header);
         else
            String'Write(Conexion'Access, Http_Common.End_Of_Header);
         end if;
         String'Write(Conexion'Access, PAG504);

         when Petition_Reply_Analysis.Bad_Syntax=>
           ---Si no existe el servidor remoto, enviamos un 502

           --De nuevo, la primera linea a devolver depende del tipo de peticion
           if Peticion.Version=Petition_Reply_Analysis.V10 then
              String'Write(conexion'access,CABECERA502_10 & Http_Common.End_Of_Header_line);
           elsif Peticion.Version=Petition_Reply_Analysis.V11 then
              String'Write(conexion'access,CABECERA502_11 & Http_Common.End_Of_Header_line);
           end if;
           String'Write(Conexion'Access,"Content-Length:"& Natural'Image(TAM_PAG502));
           --Si hay que cerrar, agregamos el Connection: Close, si no...un fin de cabeceras
           if FinConexion or flagMaxConn then
              String'Write(Conexion'Access, Http_Common.End_Of_Header_Line
                           & "Connection: Close" & Http_Common.End_Of_Header);
           else
              String'Write(Conexion'Access, Http_Common.End_Of_Header);
           end if;
           String'Write(Conexion'Access, PAG502);

      end;
   end Attend_Remote_Petition;



end Peticiones_Remotas;
