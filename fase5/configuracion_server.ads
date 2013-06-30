with ada.strings.Unbounded;
with ada.text_io;
with Ada.Streams.Stream_IO;


package configuracion_Server is

   package SIO renames ada.streams.stream_IO;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

   MAX_DOMINIOS: constant Natural:=10;
   MUESCA_FIN: constant String :="#";
   type tArrayDominios is array(1..MAX_DOMINIOS) of ASU.unbounded_String;
   --Tenemos en cuenta que el dominio por defecto, es el primero del array
   type tInfoConfiguracion is record
        dominios: tArrayDominios;
        nTotalDominios:Natural:=1;
        directorioArchivos: ASU.unbounded_String;
        MaxPeticionesPermitidas: Natural:=5;
   end record;

   --Por seguridad, hay que hacer que solo sean visibles cargar configuracion y los get.
   procedure cargarConfiguracion(config:in out tInfoConfiguracion);
   --LLama al resto de funciones para cargar la configuración.
   function get_DirectorioArchivos (config: in tInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve cual es el directorio por defecto actual
   function Get_DominioPorDefecto (config: in tInfoConfiguracion) return ASU.Unbounded_String;
   --Devuelve el dominio por defecto actual
   function Get_MaxPeticiones (Config: in TInfoConfiguracion) return Natural;
   --Devuelve el maximo numero de peticiones consecutivas permitidas en la misma conexion

end Configuracion_Server;
