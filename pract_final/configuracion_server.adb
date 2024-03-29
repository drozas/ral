-- ------------------------------------------------------------
--       Pr�ctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- M�dulo: configuracion_server
-- David Rozas Domingo
-- ------------------------------------------------------------

package body Configuracion_Server is

   procedure Set_DominioPorDefecto (config:in out tInfoConfiguracion;
                                    valor: in Asu.Unbounded_String) is
      --Asigna un valor al dominio por defecto
        begin
           config.dominios(1):=valor;
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
   end set_DirectorioArchivos;
   --------------------------------------------------------------------------------

   function get_DirectorioArchivos (config: in tInfoConfiguracion) return ASU.Unbounded_String is
      directorio: ASU.Unbounded_String;
   begin
      --Devuelve cual es el directorio por defecto actual
      directorio:= config.directorioArchivos;
      return directorio;
   end get_DirectorioArchivos;

   ------------------------------------------------------------------------------------
   procedure Set_MaxPeticiones(Config: in out TInfoConfiguracion;
                                         Valor: in Natural) is
      --Asigna el maximo n� de peticiones permitidas a una misma conexion.
   begin
      Config.MaxPeticionesPermitidas:=Valor;
   end Set_MaxPeticiones;
   ------------------------------------------------------------------------------------
   function Get_MaxPeticiones(Config: in TInfoConfiguracion) return Natural is
      --Devuelve el m�x n� de peticiones permitidas
      Max_peti: Natural:=0;
   begin
      Max_Peti:=Config.MaxPeticionesPermitidas;
      return Max_Peti;
   end Get_MaxPeticiones;

   -------------------------------------------------------------------------------------
   procedure Set_Puerto(Config: in out TInfoConfiguracion;
                         Port: in ASU.Unbounded_String) is
      --Asigna en nuestra variable de configuracion el valor del puerto al que nos hemos atado
   begin
        Config.Puerto:=  Port;
   end Set_Puerto;

   ----------------------------------------------------------------------------------------
   function Get_Puerto(Config: in TInfoConfiguracion) return ASU.Unbounded_String is
      --Devuelve el n� de puerto al que nos hemos atado desde la variable de configuracion
      PuertoDevuelto: ASU.Unbounded_string;
   begin
       PuertoDevuelto:= Config.Puerto;
       return PuertoDevuelto;
   end Get_Puerto;

   ---------------------------------------------------------------------------------------
   procedure Set_IpMaquina(Config: in out TInfoConfiguracion;
                           Ipmaq: ASU.Unbounded_String) is
      --Asigna el valor de la ip de la m�quina al registro de configuracion
   begin
        Config.ip :=Ipmaq;
   end Set_IpMaquina;

   ---------------------------------------------------------------------------------------
   function Get_IpMaquina(Config: in TInfoConfiguracion) return ASU.Unbounded_String is
      --Devuelve el valor de la ip que tenemos cargada en la variable de configuracion
      IpDevuelta: ASU.Unbounded_String;
   begin
      IpDevuelta:= Config.Ip;
      return IpDevuelta;
   end Get_IpMaquina;

   -------------------------------------------------------------------------------------
   procedure CargarDominiosLocales (config: in out tInfoConfiguracion) is
      fichero_local_domain: SIO.File_Type;
      Acceso_Fichero_local_domain: SIO.Stream_Access;
      car_Leido:character;
      cadena_leida:ASU.Unbounded_string;
      TamFichero: Natural;
   begin
      --begin (para tratamiento de excepcion)
      begin
         SIO.Open(Fichero_Local_Domain, SIO.In_File,"server_config/local_domain");
         Acceso_Fichero_Local_Domain := SIO.Stream(Fichero_Local_Domain);

         --Comprobamos que su tama�o sea mayor que 1B. Si no hay al menos un dominio (es vac�o) saltar� una excepcion.
         TamFichero := NATURAL(SIO.Size(Fichero_Local_Domain));

         if TamFichero<=1 then
            Ada.Exceptions.Raise_exception(Fichero_Vacio'Identity,
                                           "EXCEPCION!: El fichero local_domain existe; pero no alberga ningun dominio.");
         else
            --Lectura secuencial del fichero local_domain...
            while (not SIO.End_Of_File(fichero_Local_Domain)) loop
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
            --Le restamos uno, ya que el indice se aumenta una vez de m�s, por el �ltimo fin de linea.
            Config.NTotalDominios:=Config.NTotalDominios-1;

            SIO.Close(fichero_local_domain);
         end if;
      exception
         when SIO.Name_Error =>
            --tratamiento de error de apertura....
            Ada.Exceptions.Raise_Exception(SIO.Name_Error'Identity,
                                           "EXCEPCION!: No se ha podido abrir el fichero: local_domain . Puede que no exista.");
      end; --end de excepcion
   end cargarDominiosLocales;
   ----------------------------------------------------------------------------
   -----------------------------------------------------------------------------

   procedure cargarConfiguracion(config:in out TInfoConfiguracion;
                                 IpMaq: in ASU.Unbounded_String;
                                 Puerto: in ASU.Unbounded_String) is
      I: Natural:=1;
   begin
      Ada.Text_Io.Put_Line("#########################################################");
      ada.text_io.put_line("Cargando la configuracion del servidor...");
      Ada.Text_Io.Put_Line("#########################################################");
      --Cargamos la ip de nuestra m�quina
      Set_IpMaquina(Config, IpMaq);
      --Cargamos el puerto de nuestra m�quina
      Set_Puerto(Config, Puerto);
      --Cargamos los dominios locales
      CargarDominiosLocales(config);
      --Asignamos el directorio de los archivos a /webdocs
      Set_DirectorioArchivos(config, ASU.To_Unbounded_String("webdocs/"));
      -- El maximo de peticiones permitidas
      Set_MaxPeticiones(Config,5);

      --Y mostramos informacion
      ada.text_io.Put_line("->>> Se han cargado : " & Natural'Image(config.NTotalDominios) & " dominios");
      ada.text_io.Put_line("->>> Dominio por defecto : " &
                           ASU.To_String(get_DominioPorDefecto(config)));
      ada.text_io.Put_line("->>> Directorio de archivos : " & ASU.To_String(Get_DirectorioArchivos(config)));
      Ada.Text_Io.Put_Line("->>> M�ximas peticiones permitidas : " & Natural'Image(Get_MaxPeticiones(Config)));
      --LO MOSTRAMOS HASTA NDOM-1, PQ AUMENTA NDOM SEGUN FIN DE LINEA.MEJORAR!!!!!!!
      Ada.Text_Io.Put_Line("->>> Dominios locales servidos: ");
      for I in 1..(config.NTotalDominios) loop
         ada.text_io.Put_line(" ### Dominio  " & natural'Image(i) & " : "
                              & ASU.To_String(config.Dominios(i)));
      end loop;
      Ada.Text_Io.Put_Line("#########################################################");
   end cargarConfiguracion;

end configuracion_Server;
