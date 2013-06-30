with Ada.Strings.Maps;
with Ada.Exceptions;
with Ada.Text_IO;

package body Petition_Analysis is

    package Maps renames Ada.Strings.Maps;
    package Exceptions renames Ada.Exceptions;

    -- Analyze_Petition
    procedure Analyze_Petition  (   Petition_String :   in out Unbounded.Unbounded_String;
                                    Petition        :   in out Petition_Type) is
        First_Line          :   Unbounded.Unbounded_String;
        Field_Line          :   Unbounded.Unbounded_String;
        Number_of_Fields    :   natural;
        --Fields_Array_Record:   Fields_Array_Record_Type;
        Fields_Array_Access :   Fields_Array_Access_Type;
        Cr_Lf_Index         :   natural;

    begin

        -- Analyzing first line
        Cr_Lf_Index := Unbounded.Index(Petition_String, Ascii.CR & Ascii.LF & "");

        if Cr_Lf_Index = 0 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "No CR or LF char found");
        elsif Cr_Lf_Index = 1 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "First line empty");
        end if;

        First_Line := Unbounded.To_Unbounded_String(Unbounded.Slice(Petition_String, 1, Cr_Lf_Index-1));

        Analyze_First_Line(First_Line, Petition);

        -- Removing first line
        Unbounded.Delete(Petition_String, 1, Cr_Lf_Index + 1);

        -- Analyzing fields
        Number_of_Fields := Unbounded.Count(Petition_String,Ascii.CR & Ascii.LF & "") - 1;
        Petition.Number_Fields := Number_of_Fields;
        Fields_Array_Access := new Fields_Array_Record_Type(Number_of_Fields);
        Petition.Fields_Array := Fields_Array_Access;
        for Loop_Index in 1..Number_of_Fields loop
            Cr_Lf_Index := Unbounded.Index(Petition_String, Ascii.CR & Ascii.LF & "");
            Field_Line := Unbounded.To_Unbounded_String(Unbounded.Slice(Petition_String, 1,Cr_Lf_Index-1));
            Analyze_Field(Field_Line, Fields_Array_Access.Fields(Loop_Index));
           -- Removing field
           Unbounded.Delete(Petition_String, 1, Cr_Lf_Index + 1);
        end loop;

    end Analyze_Petition;


    -- Analyze_First_Line
    procedure Analyze_First_Line(   First_Line :    in out Unbounded.Unbounded_String;
                                    Petition   :    in out Petition_Type) is
        Blank_Index     :   natural;
        Method_String   :   Unbounded.Unbounded_String;
    begin

        Ada.Text_IO.Put_Line("Analyzing first line " & Unbounded.To_String(First_Line));

        -- Getting Method
        Blank_Index := Unbounded.Index(First_Line, Maps.To_Set(' '));
        if Blank_Index < 3 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "No command in first line");
        end if;
        Method_String := Unbounded.To_Unbounded_String(Unbounded.Slice(First_Line, 1, Blank_Index - 1));
        if Method_String = "GET" then
            Petition.Method := GET;
        elsif Method_String = "PUT" then
            Petition.Method := PUT;
        elsif  Method_String = "HEAD" then
           Petition.Method := HEAD;
        elsif Method_String ="POST" then
           Petition.Method:= POST;
        else
            Petition.Method := UNKNOWN;
        end if;
        -- Removing method
        Unbounded.Delete(First_Line,1,Blank_Index);

        -- Getting URI
        Blank_Index := Unbounded.Index(First_Line, Maps.To_Set(' '));
        if Blank_Index < 1 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "No URI defined");
        end if;
        -- THE URI_Analysis.Break_URI() FUNCTION IS DEFINED BY YOU!!!!
        Petition.URI := URI_Analysis.Break_URI(Unbounded.To_Unbounded_String(Unbounded.Slice(First_Line, 1, Blank_Index - 1)));
        -- Removing URI
        Unbounded.Delete(First_Line,1,Blank_Index);

        -- Getting Version
        if First_Line = "HTTP/1.0" then
            Petition.Version := V10;
        elsif First_Line = "HTTP/1.1" then
            Petition.Version := V11;
         else
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "Unknown version " & Unbounded.To_String(First_Line));
        end if;
    exception
        when Error_In_URI   :   URI_Analysis.Bad_URI_Syntax =>
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "URI not well formed: " & Exceptions.Exception_Message(Error_In_URI));
        when Error          :   Others =>
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "Unexpected error, message is: " & Exceptions.Exception_Message(Error));
    end Analyze_First_Line;


    -- Analyze_Field
    procedure Analyze_Field    (   Field_Line:    in out Unbounded.Unbounded_String;
                                    Field     :    in out Field_Type) is
        Colon_Index     :   natural;
    begin
        Ada.Text_IO.Put_Line("Analyzing field " & Unbounded.To_String(Field_Line));
        Colon_Index := Unbounded.Index(Field_Line, ":");
        if Colon_Index <=1 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "Field without colon");
        end if;
        Field.Name := Unbounded.Trim(Unbounded.To_Unbounded_String(Unbounded.Slice(Field_Line,1,Colon_Index-1)), Ada.Strings.Both);
        Field.Value := Unbounded.Trim(Unbounded.To_Unbounded_String(Unbounded.Slice(Field_Line,Colon_Index+1,Unbounded.Length(Field_Line))), Ada.Strings.Both);
    end Analyze_Field;


    -- Show_Petition_Data
    procedure Show_Petition_Data(   Petition    :   in Petition_Type) is
    begin

        -- First line
        Ada.Text_IO.Put_Line("  Method  : " & Method_Type'Image(Petition.Method));
        Ada.Text_IO.Put_Line("  URI     : Protocol " & Unbounded.To_String(Petition.URI.Protocol));
        Ada.Text_IO.Put_Line("            Host     " & Unbounded.To_String(Petition.URI.Host));
        Ada.Text_IO.Put_Line("            Port     " & Integer'Image(Petition.URI.Port));
        Ada.Text_IO.Put_Line("            Path     " & Unbounded.To_String(Petition.URI.Path));
        Ada.Text_IO.Put_Line("  Version : " & Version_Type'Image(Petition.Version));

        -- Fields
        Ada.Text_IO.Put_Line("  Number of fields : " & Integer'Image(Petition.Number_Fields));
        for Loop_Index in 1..Petition.Number_Fields loop
            Ada.Text_IO.Put_Line("    Field" & Integer'Image(Loop_Index) & " Name  : " & Unbounded.To_String(Petition.Fields_Array.Fields(Loop_Index).Name));
            Ada.Text_IO.Put_Line("    Field" & Integer'Image(Loop_Index) & " Value : " & Unbounded.To_String(Petition.Fields_Array.Fields(Loop_Index).Value));
        end loop;

        -- Body
        Ada.Text_IO.Put("  Body    : ");
        if Unbounded.Length(Petition.Pet_Body) = 0 then
            Ada.Text_IO.Put_Line(" <empty>");
        else
            Ada.Text_IO.Put_Line(Ascii.CR & Unbounded.To_String(Petition.Pet_Body));
        end if;

    end Show_Petition_Data;

end Petition_Analysis;
