-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: uri_analysis
-- David Rozas Domingo
-- ------------------------------------------------------------

with Lower_Layer_TCP;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Strings.Unbounded;


package URI_Analysis is
   Package ASU renames Ada.Strings.Unbounded;
   Package TCP renames Lower_Layer_TCP;


   Bad_Uri_Syntax: exception;

   -- Constantes y definición del tipo de datos Uri_Type
   HTTP_PROTOCOL   :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("HTTP");
   DEFAULT_PROTOCOL:   constant Ada.Strings.Unbounded.Unbounded_String := HTTP_PROTOCOL;
   DEFAULT_HOST    :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("");
   DEFAULT_PORT    :   constant Natural := 80;
   DEFAULT_PATH    :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("/");

   type URI_Type is record
      Protocol: ASU.Unbounded_String:=DEFAULT_PROTOCOL;
      host: ASU.Unbounded_string:= DEFAULT_HOST;
      Port: Natural:= DEFAULT_PORT;
      Path: ASU.Unbounded_String:= DEFAULT_PATH;
   end record;


   function Break_URI (cadena_entrada: in ASU.Unbounded_String) return URI_Type;
   -- Devuelve la URI por campos a partir de una cadena de entrada. Comprueba la correción de su sintaxis.

   procedure Inicializar_URI (Uri: in out URI_Type);
   --Inicializa un uri con sus valores por defecto (constantes)
end URI_Analysis;
