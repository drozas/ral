package body Tarea_Conexion is


   task body NuevaConexion  is
      CadenaPeticion: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
      Peticion: Petition_Type;
      NPeticiones: Integer;
      finConexion: Boolean;
      flagMaxConn: Boolean:= False;
      MAX_PETICIONES: Integer;
      EsLocal: Boolean;
      HostDevuelto: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
   begin
      --Cerraremos la conexion despues de 5 seguidas, o cuando lo marque el booleano
      MAX_PETICIONES:= Get_MaxPeticiones(PDatosTarea.Configuracion);
      --Inicializamos variables de fuera de bucle...
      NPeticiones:=0;
      flagMaxConn:=FALSE;

      loop

         --Inicializaci�n de variables internas
         FinConexion:=FALSE;
         NPeticiones:=NPeticiones+1;

         --Activamos el flag cuando es la �ltima conexi�n permitida, para avisar a los modulos internos
         if NPeticiones=MAX_PETICIONES then
            flagMaxConn:= TRUE;
         end if;

         --Leemos la peticion
         Http_Common.LeerCabecera(PDatosTarea.Conexion, CadenaPeticion);
         Ada.Text_Io.Put_Line("");
         Ada.Text_Io.Put_Line(" -------------------- Inicio de petici�n --------------------");
         begin
            Analyze_Petition(cadenaPeticion,Peticion);

            HostDevuelto:= EsHostLocalValido(Peticion,PdatosTarea.Configuracion);
            --Si el que nos devuelve es distinto de nulo, es que es un host local valido
            if  HostDevuelto/=ASU.Null_Unbounded_String then
               Ada.Text_Io.Put_Line("Tipo de petici�n: Local");
               --################ TRATAMIENTO DE PETICIONES LOCALES ###############################
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  -- Llamamos a la funcion de atender peticiones, del paquete Http10
                  Ada.Text_Io.Put_Line("Versi�n de protocolo: HTTP 1.0");
                  http_10.Attend_Petition_http10(Peticion,pDatosTarea.Conexion,
                                                 PDatosTarea.Configuracion,HostDevuelto,
                                                 FinConexion,flagMaxConn);

               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  -- Llamamos a la funcion de atender peticiones, del paquete http11
                  Ada.Text_Io.Put_Line("Versi�n de protocolo: HTTP 1.1 ");
                  http_11.Attend_Petition_Http11(Peticion,pDatosTarea.Conexion,
                                                 pDatosTarea.Configuracion,HostDevuelto,
                                                 FinConexion,flagMaxConn);

               end if;
               --####################################################################################

            elsif (Http_Common.EsHostRemotoValido(Peticion)/= ASU.Null_Unbounded_String) then
               HostDevuelto:= EsHostRemotoValido(Peticion);
               Ada.Text_Io.Put_Line("Tipo de petici�n: Remota");
               --################ TRATAMIENTO DE PETICIONES REMOTAS  ###############################
               Peticiones_Remotas.Attend_Remote_Petition(Peticion,PDatosTarea.Conexion,
                                                         HostDevuelto,FinConexion,flagMaxConn);
               --####################################################################################

            else
               --Si el host no es v�lido, devolvemos un error 400
               Ada.Text_Io.Put_Line("Host inv�lido. Devolveremos 400 (bad request que salta por esHostLocal)");
               --Vamos a cerrar...asi ke cabecera y Connection close
               --la cabecera a devolver depende del tipo de peticion
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(PDatosTarea.conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(PDatosTarea.conexion'access,CABECERA400_11 & Http_Common.End_Of_Header_line);
               end if;
               String'Write(PDatosTarea.Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
               --Cerramos la conexion forzosamente, por Bad Request
               FinConexion:=TRUE;

            end if;

            exception
            when Petition_Reply_Analysis.Bad_Syntax =>
               Ada.Text_Io.Put_Line("Bad Request que salta de excepcion de Analyze_Petition");
               --Liberaremos la conexion si hubo un Bad Request. Escribimos la cabecera...
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(PDatosTarea.conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(PDatosTarea.conexion'access,CABECERA400_11 & Http_Common.End_Of_Header_line);
               end if;
               --y el connection_close
               String'Write(pDatosTarea.Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
               FinConexion:=TRUE;
         end;

         Ada.Text_Io.Put_Line("");
         Ada.Text_Io.Put_Line(" ---------------------- Fin de petici�n ----------------------");

         -- #################### Tratamiento de cierre de conexion ######################################
         if FinConexion then
            --Si se cerro la conexion por mandato de alguna cabecera...
            Ada.Text_Io.Put_Line("@@@@@@ Cierre de conexion : el servidor cierra la conexi�n @@@@@@");
            TCP.Dispose (pDatosTarea.Conexion);
         elsif NPeticiones>=MAX_PETICIONES then
            --Si fue por n� de peticiones, el connection close se supone que ya lo hemos enviado
            FinConexion:=TRUE;
            Ada.Text_Io.Put_Line("@@@@@ Cierre de conexion: el servidor cierra la conexi�n despu�s de 5 conexiones seguidas @@@@");
            TCP.Dispose (pDatosTarea.Conexion);
         end if;
         --#############################################################################################


         exit when FinConexion;
      end loop;
   end NuevaConexion;


end Tarea_Conexion;
