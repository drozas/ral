with Petition_Analysis; use Petition_Analysis;
with Ada.Strings.Unbounded;

package http_Aux is

   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;
   
   --CONSTANTES DE CABECERAS Y CARACTERES DE FIN DE LINEA Y FIN DE DE CABECERA
   ---------------------------------------------------------------------------------------
   End_of_Header_Line : constant String (1..2) := Ascii.CR & Ascii.LF;
   End_of_Header      : constant String (1..4) := End_of_Header_Line & End_of_Header_Line;

   CABECERA400: constant String:=
     "HTTP/1.0 400 Bad Request" & End_Of_Header_Line;

   CABECERA404: constant String:=
     "HTTP/1.0 404 Not Found" & End_Of_Header_Line;

   CABECERA501: constant String:=
     "HTTP/1.0 501 Not Implemented" & End_Of_Header_Line;

   CABECERA200: constant String:=
     "HTTP/1.0 200 OK" & End_Of_Header_Line;

   CABECERA505: constant string:=
	 "HTTP/1.1 505 HTTP Version Not Supported" & End_of_Header_line;
   ----------------------------------------------------------------------------------------

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return Boolean;

   function ExisteCampo(Peticion: in Petition_Type;
                        Campo: in ASU.Unbounded_String) return Boolean;

end http_Aux;

