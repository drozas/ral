-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: tarea_conexion
-- David Rozas Domingo
-- ------------------------------------------------------------

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
      --Cerraremos la conexion despues de MAX_PETICIONES seguidas, o cuando lo marque el booleano (por cabeceras)
      MAX_PETICIONES:= Get_MaxPeticiones(PDatosTarea.Configuracion);
      --Inicialización de variables externas al bucle.
      NPeticiones:=0;
      flagMaxConn:=FALSE;

      loop

         --Inicialización de variables internas al bucle.
         FinConexion:=FALSE;
         NPeticiones:=NPeticiones+1;

         --Activamos el flag cuando es la última conexión permitida, para avisar a los modulos internos
         if NPeticiones=MAX_PETICIONES then
            flagMaxConn:= TRUE;
         end if;

         --Leemos la peticion
         Http_Common.LeerCabecera(PDatosTarea.Conexion, CadenaPeticion);
         Ada.Text_Io.Put_Line("");
         Ada.Text_Io.Put_Line(" -------------------- Análisis de petición --------------------");
         begin
            Analyze_Petition(cadenaPeticion,Peticion);

            HostDevuelto:= EsHostLocalValido(Peticion,PdatosTarea.Configuracion);
            --Si el que nos devuelve es distinto de nulo, es que es un host local valido
            if  HostDevuelto/=ASU.Null_Unbounded_String then
               Ada.Text_Io.Put_Line("Tipo de petición: Local");

               --################ TRATAMIENTO DE PETICIONES LOCALES ###############################
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  -- Llamamos a la funcion de atender peticiones, del paquete Http10
                  Ada.Text_Io.Put_Line("Versión de protocolo: HTTP 1.0");
                  http_10.Attend_Petition_http10(Peticion,pDatosTarea.Conexion,
                                                 PDatosTarea.Configuracion,HostDevuelto,
                                                 FinConexion,flagMaxConn);

               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  -- Llamamos a la funcion de atender peticiones, del paquete http11
                  Ada.Text_Io.Put_Line("Versión de protocolo: HTTP 1.1 ");
                  http_11.Attend_Petition_Http11(Peticion,pDatosTarea.Conexion,
                                                 pDatosTarea.Configuracion,HostDevuelto,
                                                 FinConexion,flagMaxConn);

               end if;
               --####################################################################################

            elsif (Http_Common.EsHostRemotoValido(Peticion)/= ASU.Null_Unbounded_String) then
               HostDevuelto:= EsHostRemotoValido(Peticion);
               Ada.Text_Io.Put_Line("Tipo de petición: Remota");

               --################ TRATAMIENTO DE PETICIONES REMOTAS  ###############################
               Peticiones_Remotas.Attend_Remote_Petition(Peticion,PDatosTarea.Conexion,
                                                         HostDevuelto,FinConexion,flagMaxConn);
               --####################################################################################

            else
               --Si el host no es válido, devolvemos un error 400
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(PDatosTarea.conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(PDatosTarea.conexion'access,CABECERA400_11 & Http_Common.End_Of_Header_line);
               end if;
               String'Write(PDatosTarea.Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
               FinConexion:=TRUE;

            end if;

            exception
            when Petition_Reply_Analysis.Bad_Syntax =>
               -- Si hubo mala sintaxis, devolvemos un error 400
               if Peticion.Version=Petition_Reply_Analysis.V10 then
                  String'Write(PDatosTarea.conexion'access, CABECERA400_10 & Http_Common.End_Of_Header_line);
               elsif Peticion.Version=Petition_Reply_Analysis.V11 then
                  String'Write(PDatosTarea.conexion'access,CABECERA400_11 & Http_Common.End_Of_Header_line);
               end if;
               String'Write(pDatosTarea.Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
               FinConexion:=TRUE;
         end;


         -- ######################### Acción de cierre de conexion ######################################
         if FinConexion then
            -- Podemos cerrar por lo que nos han indicado valores de cabecera
            TCP.Dispose (pDatosTarea.Conexion);
         elsif NPeticiones>=MAX_PETICIONES then
            -- O por superar el exceso de peticiones.
            FinConexion:=TRUE;
            TCP.Dispose (pDatosTarea.Conexion);
         end if;
         --#############################################################################################


         exit when FinConexion;

      end loop;

   end NuevaConexion;

end Tarea_Conexion;
