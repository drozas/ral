-- ------------------------------------------------------------
--       Práctica de RAL (3 ITIS): SERVIDOR HTTP
--       ------------------------------------------
-- Módulo: petition_reply_analysis (se han agregado funciones)
-- David Rozas Domingo
-- ------------------------------------------------------------

with Ada.Strings.Unbounded;
with URI_Analysis;

use Ada.Strings.Unbounded;

package Petition_Reply_Analysis is

   package Unbounded renames Ada.Strings.Unbounded;
   -- Ada.Strings.Unbounded es dos veces renombrado, pero no da problema. Nosotros usamos ASU
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;

    -- TYPES DECLARATIONS

    type Field_Type is
        record
            Name    :   Unbounded.Unbounded_String;
            Value   :   Unbounded.Unbounded_String;
        end record;
    type Fields_Array_Type is array(Integer range<>) of Field_Type;
    type Fields_Array_Record_Type(Number_of_Fields : Integer)  is
        record
            Fields :   aliased Fields_Array_Type(1..Number_of_Fields);
        end record;
    type Fields_Array_Access_Type is access Fields_Array_Record_Type;

    type Method_Type    is (GET, HEAD, PUT, POST, UNKNOWN);
    type Version_Type   is (V10, V11);

    type Petition_Type is
        record
            Method          :   Method_Type;
            URI             :   URI_Analysis.URI_Type;
            Version         :   Version_Type;
            Number_Fields   :   Natural;
            Fields_Array    :   Fields_Array_Access_Type;
            Pet_Body        :   Unbounded.Unbounded_String;
        end record;

    type Reply_Type is
        record
            First_Line      :   Unbounded.Unbounded_String;
            Fields_Array    :   Fields_Array_Access_Type;
            Reply_Body      :   Unbounded.Unbounded_String;
        end record;

    Bad_Syntax  :   exception;

    -- METHODS DECLARATIONS

    procedure Analyze_Petition  (  Petition_String  :   in out Unbounded.Unbounded_String;
                                   Petition         :   in out Petition_Type);

    procedure Analyze_First_Line(  First_Line       :   in out Unbounded.Unbounded_String;
                                   Petition         :   in out Petition_Type);

    procedure Analyze_Field     (  Field_Line       :   in out Unbounded.Unbounded_String;
                                   Field            :   in out Field_Type);

    procedure Analyze_Reply     (   Reply_String    :   in out Unbounded.Unbounded_String;
                                    Reply           :   in out Reply_Type);

    procedure Show_Petition_Data(  Petition         :   in Petition_Type);

    procedure Add_Field         (   Fields_Array    :   in out Fields_Array_Access_Type;
                                    Field_Name      :   in String;
                                    Field_Value     :   in String);

    procedure Remove_Field      (   Fields_Array    :   in out Fields_Array_Access_Type;
                                    Field_Name      :   in String);


    --############### FUNCIONES AGREGADAS ###########################################

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return Boolean;
   --Nos dice si el valor que le pasamos, es igual al del campo que queremos

   function ExisteCampo(Peticion: in Petition_Type;
                        Campo: in ASU.Unbounded_String) return Boolean;
   --Nos devuelve un booleano indicando la existencia del campo


   function DameValorCampo(Peticion: in  Petition_Type;
                           Campo: in ASU.Unbounded_String) return ASU.Unbounded_String;

   --funcion auxiliar, que nos devuelve el valor de un campo dado en un unbounded

    function ExisteCampoResp(Respuesta: in Reply_Type;
                             Campo: in ASU.Unbounded_String) return Boolean;
    --Funcion auxiliar, que nos dice si existe un campo (para tipo reply)

    function DameValorCampoResp(Respuesta: in  Reply_Type;
                                Campo: in ASU.Unbounded_String) return ASU.Unbounded_String;

    --funcion auxiliar, que nos devuelve el valor de un campo de una respuesta en un unbounded

   --################# MÉTODOS PARA PETICIONES REMOTAS ###########################
   function Build_Petition (Peticion: in Petition_Type) return ASU.Unbounded_String;
   --Construye la peticion para enviarsela al servidor remoto

   function Build_Reply (Reply_Remoto: in Reply_Type;
                         FinConexion:in Boolean;
                         FlagMaxConn: in Boolean) return ASU.Unbounded_String;
   --Construye un unbounded para devolver al cliente, a partir de la respuesta del host remoto

   end Petition_Reply_Analysis;
