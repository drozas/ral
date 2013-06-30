with Ada.Strings.Unbounded;
with URI_Analysis;

use Ada.Strings.Unbounded;

package Petition_Analysis is

    package Unbounded renames Ada.Strings.Unbounded;

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
            -- THE URI_Analysis.URI TYPE IS DEFINED BY YOU!!!!
            URI             :   URI_Analysis.URI_Type;
            Version         :   Version_Type;
            Number_Fields   :   Natural;
            Fields_Array    :   Fields_Array_Access_Type;
            Pet_Body        :   Unbounded.Unbounded_String;
        end record;

    Bad_Syntax  :   exception;

    -- METHODS DECLARATIONS

    procedure Analyze_Petition  (   Petition_String :   in out Unbounded.Unbounded_String;
                                    Petition        :   in out Petition_Type);

    procedure Analyze_First_Line(   First_Line      :   in out Unbounded.Unbounded_String;
                                    Petition        :   in out Petition_Type);

    procedure Analyze_Field    (   Field_Line     :   in out Unbounded.Unbounded_String;
                                   Field          :   in out Field_Type);

    procedure Show_Petition_Data(   Petition    :   in Petition_Type);

end Petition_Analysis;
