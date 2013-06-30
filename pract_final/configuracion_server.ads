-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: configuracion_server
-- David Rozas Domingo
-- ------------------------------------------------------------

with ada.strings.Unbounded;
with ada.text_io;
with Ada.Streams.Stream_IO;
with Ada.Exceptions;
--llamadas a paquetes necesarios para conseguir la ip
with Lower_Layer.Inet.Misc;
with Ada_Sockets;


package configuracion_Server is

   package SIO renames ada.streams.stream_IO;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

   Fichero_Vacio: exception;
   MAX_DOMINIOS: constant Natural:=10;
   MUESCA_FIN: constant String :="#";
   type tArrayDominios is array(1..MAX_DOMINIOS) of ASU.unbounded_String;
   --Tenemos en cuenta que el dominio por defecto, es el primero del array
   type tInfoConfiguracion is record
      dominios: tArrayDominios;
      nTotalDominios:Natural:=1;
      directorioArchivos: ASU.unbounded_String;
      MaxPeticionesPermitidas: Natural:=5;
      Ip: ASU.Unbounded_String;
      Puerto: ASU.Unbounded_String;
   end record;

   --Por seguridad solo hacemos visibles cargar configuracion y los get.
   procedure cargarConfiguracion(config:in out TInfoConfiguracion;
                                 IpMaq: in ASU.Unbounded_String;
                                 Puerto: in ASU.Unbounded_String);
   --LLama al resto de funciones para cargar la configuración.
   function get_DirectorioArchivos (config: in tInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve cual es el directorio por defecto actual
   function Get_DominioPorDefecto (config: in tInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve el dominio por defecto actual
   function Get_MaxPeticiones (Config: in TInfoConfiguracion) return Natural;
   --Devuelve el maximo numero de peticiones consecutivas permitidas en la misma conexion
   function Get_IpMaquina(Config: in TInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve el valor de la ip que tenemos cargada en la variable de configuracion
   function Get_Puerto(Config: in TInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve el nº de puerto al que nos hemos atado desde la variable de configuracion


   end Configuracion_Server;
