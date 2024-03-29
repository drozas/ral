-- -------------------------------------------------------------
--�       Pr�ctica de RAL (3� ITIS): Fase 2
--        ---------------------------------
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

        -- Constantes y definici�n del tipo de datos Uri_Type
   HTTP_PROTOCOL   :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("HTTP");

   DEFAULT_PROTOCOL:   constant Ada.Strings.Unbounded.Unbounded_String := HTTP_PROTOCOL;
   DEFAULT_HOST    :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("");
   DEFAULT_PORT    :   constant Natural := 80;
   DEFAULT_PATH    :   constant Ada.Strings.Unbounded.Unbounded_String := ASU.To_Unbounded_String("/");
   Bad_Uri_Syntax: exception;


   type URI_Type is record
      Protocol: ASU.Unbounded_String:=DEFAULT_PROTOCOL;
      host: ASU.Unbounded_string:= DEFAULT_HOST;
      Port: Natural:= DEFAULT_PORT;
      Path: ASU.Unbounded_String:= DEFAULT_PATH;
   end record;


   function Break_URI (cadena_entrada: in ASU.Unbounded_String) return URI_Type;
   procedure Inicializar_URI (Uri: in out URI_Type);
end URI_Analysis;
