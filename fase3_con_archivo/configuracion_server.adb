package body Configuracion_Server is

   --Funciones auxiliares que utiliza el CargarConfiguracion...
   ----------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------
   procedure Set_DominioPorDefecto (config:in out tInfoConfiguracion;
                                    valor: in Asu.Unbounded_String) is
      --Asigna un valor al dominio por defecto
        begin
           config.dominios(1):=valor;
           ada.text_io.Put_line("Asignando dominio por defecto : " & ASU.To_String(config.dominios(1)));
        end set_DominioPorDefecto;
   ---------------------------------------------------------------------------------------

   function Get_DominioPorDefecto (config: in tInfoConfiguracion) return ASU.Unbounded_String is
      --Devuelve el dominio por defecto actual
      dominio: ASU.Unbounded_String;
   begin
      dominio:=config.dominios(1);
      return dominio;
   end Get_DominioPorDefecto;
   -------------------------------------------------------------------------------------

   procedure set_DirectorioArchivos (config: in out tInfoConfiguracion;
                                     valor: in ASU.Unbounded_String) is
      --Asigna un valor al directorio de archivos por defecto
   begin
      config.DirectorioArchivos:=valor;
      ada.text_io.Put_line("Asignando directorio de archivos: " & aSU.To_String(config.directorioArchivos));
   end set_DirectorioArchivos;
   --------------------------------------------------------------------------------

   function get_DirectorioArchivos (config: in tInfoConfiguracion) return ASU.Unbounded_String is
      directorio: ASU.Unbounded_String;
   begin
      --Devuelve cual es el directorio por defecto actual
      directorio:= config.directorioArchivos;
      return directorio;
   end get_DirectorioArchivos;
-------------------------------------------------------------------------------------
   procedure CargarDominiosLocales (config: in out tInfoConfiguracion) is
      fichero_local_domain: SIO.File_Type;
      Acceso_Fichero_local_domain: SIO.Stream_Access;
      car_Leido:character;
      cadena_leida:ASU.Unbounded_string;
   begin
      --begin para tratamiento de excepcion...
      begin
         SIO.Open(Fichero_Local_Domain, SIO.In_File,"server_config/local_domain");
         Acceso_Fichero_Local_Domain := SIO.Stream(Fichero_Local_Domain);
         --Lectura secuencial del fichero local_domain...
         --LEE UNO MÁS!!, ya que aumentamos cada fin de línea...
         --¿¿¿ALGUNA FORMA DE CONTROLARLO QUE NO SEA MOSTRAR DE 1..NDOM-1???
         while not SIO.End_Of_File(fichero_Local_Domain) loop
            --Leemos caracter a caracter...
            character'Read(acceso_fichero_Local_Domain,car_leido);
            --Si es fin de linea...
            if car_leido=ascii.LF then
               --Lo guardamos
               config.dominios(config.NTotalDominios):=cadena_leida;
               --Actualizamos el indice
               config.NTotalDominios:=config.NTotalDominios+1;
               --Inicializamos de nuevo la cadena
               cadena_leida:=ASU.Null_Unbounded_string;
            else
               --si no, es que forma parte de la cadena, asi que lo metemos...
               cadena_Leida:=cadena_leida & car_Leido;
            end if;
         end loop;

         SIO.Close(fichero_local_domain);

      exception
         when SIO.Name_Error =>
            --tratamiento de error de apertura....
            ada.Text_io.put_line("EXCEPCION!: No se ha podido abrir el fichero local_domain");
      end; --end de excepcion
   end cargarDominiosLocales;
----------------------------------------------------------------------------
-----------------------------------------------------------------------------

   procedure cargarConfiguracion(config:in out tInfoConfiguracion) is
      I: Natural:=1;
   begin
      ada.text_io.put_line("Cargando la configuracion del servidor...");
      Ada.Text_Io.Put_Line("---------------------------------------------------------");
      --Cargamos los dominios locales
      CargarDominiosLocales(config);
      ada.text_io.Put_line("-> dominios locales cargados");
      --Asignamos el directorio de los archivos a /webdocs
      Set_DirectorioArchivos(config, ASU.To_Unbounded_String("webdocs/"));
      --Y mostramos informacion
      ada.text_io.Put_line("-> se han cargado " & Natural'Image(config.NTotalDominios-1) & " dominios");
      ada.text_io.Put_line("-> el dominio por defecto es: " &
                           ASU.To_String(get_DominioPorDefecto(config)));
      ada.text_io.Put_line("-> directorio de archivos web : " & ASU.To_String(Get_DirectorioArchivos(config)));

      --LO MOSTRAMOS HASTA NDOM-1, PQ AUMENTA NDOM SEGUN FIN DE LINEA.MEJORAR!!!!!!!
      Ada.Text_Io.Put_Line("Dominios cargados...");
      for I in 1..(config.NTotalDominios-1) loop
         ada.text_io.Put_line("dominio  " & natural'Image(i) & " : "
                              & ASU.To_String(config.Dominios(i)));
      end loop;
      Ada.Text_Io.Put_Line("---------------------------------------------------------");
   end cargarConfiguracion;

end configuracion_Server;
