-- ------------------------------------------------------------
--       Pr�ctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- M�dulo: test_configuracion (programa para probar el correcto funcionamiento
--                             del modulo configuracion_server)
-- David Rozas Domingo
-- ------------------------------------------------------------

with configuracion_server; use configuracion_Server;
with ada.strings.Unbounded;
with ada.text_io;

procedure test_Configuracion is
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

   configuracion:tInfoConfiguracion;
   i:natural:=1;

begin
        cargarConfiguracion(configuracion);
        ada.text_io.Put_line("Ruta de archivos por defecto : " & ASU.To_String(Get_DirectorioArchivos(configuracion)));
        ada.text_io.put_line("Directorio por defecto : " & ASU.To_String(get_DominioPorDefecto(configuracion)));
        for i in 1..(configuracion.NTotalDominios) loop
           ada.text_io.Put_line("dominio  " & natural'Image(i) & " : "
                                & ASU.To_String(configuracion.Dominios(i)));
        end loop;
end test_Configuracion;
