package body Tarea_Conexion is


   task body NuevaConexion  is
      CadenaPeticion: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
      Peticion: Petition_Type;
      NPeticiones: Integer;
      --Configuracion: TInfoConfiguracion;
      finConexion: Boolean;
      flagMaxConn: Boolean:= False;
      MAX_PETICIONES: Integer:= 69;
      A_Char: Character;
      LF_Found: Boolean := False;
   begin
      --Cerraremos la conexion despues de 5 seguidas, o cuando lo marque el booleano
      --Cargamos la conexion en cada nueva conexion (esto lo he cambiado al trabajar con tareas.!)
      --CargarConfiguracion(Configuracion);
      MAX_PETICIONES:= Get_MaxPeticiones(PDatosTarea.Configuracion);
      --Inicializamos variables de fuera de bucle...
      NPeticiones:=0;
      flagMaxConn:=FALSE;

      loop
         --Inicialización de variables internas
         FinConexion:=FALSE;
         cadenaPeticion:=ASU.Null_Unbounded_String;

         NPeticiones:=NPeticiones+1;

         --Si es la 5ª peticion, avisaremos a los modulos internos de que tienen que agregar
         --el campo de Connection: Close
         if NPeticiones=MAX_PETICIONES then
            flagMaxConn:= TRUE;
         end if;

         -- Lectura de la peticion
         LF_Found:= False;
         loop
            Character'Read (pDatosTarea.Conexion'Access, A_Char);
            CadenaPeticion:=CadenaPeticion & A_Char;
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

         begin
            Analyze_Petition(cadenaPeticion,Peticion);

            if Peticion.Version=Petition_Analysis.V10 then
               -- Llamamos a la funcion de atender peticiones, del paquete Http10
               Ada.Text_Io.Put_Line("Vamos a tratar una peticion de tipo HTTP 1.0");
               http_10.Attend_Petition_http10(Peticion,pDatosTarea.Conexion,PDatosTarea.Configuracion,FinConexion,flagMaxConn);

            elsif Peticion.Version=Petition_Analysis.V11 then
               -- Llamamos a la funcion de atender peticiones, del paquete http11
               Ada.Text_Io.Put_Line("Vamos a tratar una peticion de  tipo HTTP 1.1");
               http_11.Attend_Petition_Http11(Peticion,pDatosTarea.Conexion,pDatosTarea.Configuracion,FinConexion,flagMaxConn);

            end if;

            exception
            when Petition_Analysis.Bad_Syntax =>
               Ada.Text_Io.Put_Line("Bad Request del SERVER!!!");
               --Liberaremos la conexion si hubo un Bad Request. Escribimos la cabecera...
               String'Write(pDatosTarea.Conexion'Access, CABECERA400_10 & Http_Common.End_Of_Header_Line);
               --y el connection_close
               String'Write(pDatosTarea.Conexion'Access, "Connection: Close" & Http_Common.End_Of_Header);
               FinConexion:=TRUE;
         end;

         if FinConexion then
            --Si se cerro la conexion por mandato de alguna cabecera...
            --¿¿¿Es aquí donde metemos el connection close, no?
            Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Cierre de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
            Ada.Text_Io.Put_Line("El servidor ha cerrado la conexion.");
            TCP.Dispose (pDatosTarea.Conexion);
         elsif NPeticiones>=MAX_PETICIONES then
            --Si fue por nº de peticiones, el connection close se supone que ya lo hemos enviado
            FinConexion:=TRUE;
            Ada.Text_Io.Put_Line("@@@@@@@@@@@@@@@@@@@@@@@@@@ Cierre de conexion @@@@@@@@@@@@@@@@@@@@@@@@@@");
            Ada.Text_Io.Put_line("El servidor cierra la conexion, despues de 5 conexiones seguidas.");
            TCP.Dispose (pDatosTarea.Conexion);
         end if;

         exit when FinConexion;
      end loop;
   end NuevaConexion; --end de tarea


end Tarea_Conexion; -- end de paquete
