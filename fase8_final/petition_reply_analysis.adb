with Ada.Strings.Maps;
with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;
with Ada.Exceptions;
with Ada.Text_IO;

with HTTP_Common;

package body Petition_Reply_Analysis is

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
           -- Removing fields
           Unbounded.Delete(Petition_String, 1, Cr_Lf_Index + 1);
        end loop;

    end Analyze_Petition;


    -- Analyze_First_Line
    procedure Analyze_First_Line(   First_Line :    in out Unbounded.Unbounded_String;
                                    Petition   :    in out Petition_Type) is
        Blank_Index     :   natural;
        Method_String   :   Unbounded.Unbounded_String;
    begin

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
        elsif  Method_String = "POST" then
            Petition.Method := POST;
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
        Ada.Text_IO.Put_Line("  Method  : " & Method_Type'Image(Petition.Method));
        Ada.Text_IO.Put_Line("  URI     : Protocol " & Unbounded.To_String(Petition.URI.Protocol));
        Ada.Text_IO.Put_Line("            Host     " & Unbounded.To_String(Petition.URI.Host));
        Ada.Text_IO.Put_Line("            Port     " & Integer'Image(Petition.URI.Port));
        Ada.Text_IO.Put_Line("            Path     " & Unbounded.To_String(Petition.URI.Path));
        Ada.Text_IO.Put_Line("  Version : " & Version_Type'Image(Petition.Version));
        Ada.Text_IO.Put_Line("  Number of fields : " & Integer'Image(Petition.Fields_Array.Fields'Last));
        for Loop_Index in 1..Petition.Fields_Array.Fields'Last loop
        Ada.Text_IO.Put_Line("    Field" & Integer'Image(Loop_Index) & " Name  : " & Unbounded.To_String(Petition.Fields_Array.Fields(Loop_Index).Name));
        Ada.Text_IO.Put_Line("    Field" & Integer'Image(Loop_Index) & " Value : " & Unbounded.To_String(Petition.Fields_Array.Fields(Loop_Index).Value));
        end loop;
        Ada.Text_IO.Put("  Body    : ");
        if Unbounded.Length(Petition.Pet_Body) = 0 then
            Ada.Text_IO.Put_Line(" <empty>");
        else
            Ada.Text_IO.Put_Line(Ascii.CR & Unbounded.To_String(Petition.Pet_Body));
        end if;
    end Show_Petition_Data;


    -- Add field
    procedure Add_Field     (   Fields_Array   :   in out Fields_Array_Access_Type;
                                Field_Name     :   in String;
                                Field_Value    :   in String) is
        Number_of_Fields   :   natural;
        Aux_Fields_Array   :   Fields_Array_Access_Type;
    begin
        -- Creating new array of fields
        Number_of_Fields := Fields_Array.Fields'Last + 1;
        Aux_Fields_Array := new Fields_Array_Record_Type(Number_of_Fields);
        for Loop_Index in 1..Number_of_Fields-1 loop
            Aux_Fields_Array.Fields(Loop_Index) := Fields_Array.Fields(Loop_Index);
        end loop;

        -- Adding new field
        Aux_Fields_Array.Fields(Number_of_Fields).Name := Unbounded.To_Unbounded_String(Field_Name);
        Aux_Fields_Array.Fields(Number_of_Fields).Value := Unbounded.To_Unbounded_String(Field_Value);

        -- Updating field array in petition
        Fields_Array := Aux_Fields_Array;
    end Add_Field;


    -- Remove field
    procedure Remove_Field (    Fields_Array   :   in out Fields_Array_Access_Type;
                                Field_Name     :   in String) is
        Number_of_Fields   :   natural := 0;
        Field_Index        :   natural := 0;
        Field_Name_Low     :   String := Ada.Strings.Fixed.Translate(Field_Name, Ada.Strings.Maps.Constants.Lower_Case_Map);
        Aux_Fields_Array   :   Fields_Array_Access_Type;
        Field_Passed       :   boolean := false;
    begin
       Ada.Text_Io.Put_Line("entro en Remove-Field :vamos a intentar borrar el campo:" & Field_Name);
       -- Checking if field present in petition
        Number_of_Fields := Fields_Array.Fields'Last;
        if Number_of_Fields = 0 then
           Ada.Text_Io.Put_Line("no hay campos, salgo de remove_field");
            return;
        end if;
        for Loop_Index in 1..Number_of_Fields loop
            if Unbounded.Translate(Fields_Array.Fields(Loop_Index). Name,Ada.Strings.Maps.Constants.Lower_Case_Map) = Field_Name_Low then
                Field_Index := Loop_Index;
                exit;
            end if;
        end loop;
        if Field_Index = 0 then
           Ada.Text_Io.Put_Line("no hemos encontrado, salgo de remove_field");
            return;
        end if;

        -- Creating new fields array
        Aux_Fields_Array := new Fields_Array_Record_Type(Fields_Array.Fields'Last - 1);
        for Loop_Index in 1..Fields_Array.Fields'Last loop
            if Loop_Index = Field_Index then
                Field_Passed := true;
            elsif Field_Passed then
                Aux_Fields_Array.Fields(Loop_Index-1) := Fields_Array.Fields(Loop_Index);
            else
                Aux_Fields_Array.Fields(Loop_Index) := Fields_Array.Fields(Loop_Index);
            end if;
        end loop;
        Ada.Text_Io.Put_Line("hemos encontrado, salgo de remove field");
        Fields_Array := Aux_Fields_Array;
    end Remove_Field;


    procedure Analyze_Reply (   Reply_String   :    in out Unbounded.Unbounded_String;
                                Reply          :    in out Reply_Type) is
        First_Line          :   Unbounded.Unbounded_String;
        Field_Line         :   Unbounded.Unbounded_String;
        Number_of_Fields   :   natural;
        Fields_Array_Access:   Fields_Array_Access_Type;
        Cr_Lf_Index         :   natural;
    begin
        -- Getting first line
        Cr_Lf_Index := Unbounded.Index(Reply_String, Ascii.CR & Ascii.LF & "");
        if Cr_Lf_Index = 0 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "No CR or LF char found");
        elsif Cr_Lf_Index = 1 then
            Exceptions.Raise_Exception(Bad_Syntax'Identity, "First line empty");
        end if;
        Reply.First_Line := Unbounded.To_Unbounded_String(Unbounded.Slice(Reply_String, 1, Cr_Lf_Index-1));

        -- Removing first line
        Unbounded.Delete(Reply_String, 1, Cr_Lf_Index + 1);

        -- Analyzing fields
        Number_of_Fields := Unbounded.Count(Reply_String,Ascii.CR & Ascii.LF & "") - 1;
        Fields_Array_Access := new Fields_Array_Record_Type(Number_of_Fields);
        Reply.Fields_Array := Fields_Array_Access;
        for Loop_Index in 1..Number_of_Fields loop
            Cr_Lf_Index := Unbounded.Index(Reply_String, Ascii.CR & Ascii.LF & "");
            Field_Line := Unbounded.To_Unbounded_String(Unbounded.Slice(Reply_String, 1,Cr_Lf_Index-1));
            Analyze_Field(Field_Line, Fields_Array_Access.Fields(Loop_Index));
           -- Removing fields
           Unbounded.Delete(Reply_String, 1, Cr_Lf_Index + 1);
        end loop;

    end Analyze_Reply;

    --############################ IMPLEMENTACI�N DE M�TODOS AGREGADOS ##############################
    function CoincideCampo(peticion: in Petition_Type;
                           campo: in ASU.Unbounded_String;
                           Valor:in ASU.Unbounded_String) return boolean is
       --Le pasamos un campo, y un posible valor, y nos devuelve un booleano
       --diciendo si el valor es igual
       i: integer:=1;
       CampoEncontrado: boolean:= FALSE;
       IgualValor:Boolean:=FALSE;
    begin

       while i<=Peticion.Fields_Array.Fields'Last and (not CampoEncontrado) loop
          --Si lo encontramos, miramos si coincide el valor..
          if peticion.fields_Array.Fields(i).Name = Campo then
             CampoEncontrado:=TRUE;

             if Peticion.Fields_Array.Fields(i).Value=valor then
                IgualValor:=TRUE;
             end if;
         end if;
          i:=i+1;
       end loop;
       --Devolvemos el booleano que nos dice si el valor coincidi�.
       return IgualValor;
    end CoincideCampo;

    -----------------------------------------------------------------------------------------
    function ExisteCampo(Peticion: in Petition_Type;
                         Campo: in ASU.Unbounded_String) return Boolean is
       --Funcion auxiliar, que nos dice si existe un campo en las cabeceras
       I: Integer:=1;
      Encontrado:Boolean:=FALSE;
    begin
       --Recorremos todos los posibles campos comparando...
       while (I<=Peticion.Fields_Array.Fields'Last) and (not Encontrado) loop
         if Peticion.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=True;
         end if;
         I:=i+1;
       end loop;
       --Y devolvemos el booleano
      return Encontrado;
    end ExisteCampo;

    --------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------
    function DameValorCampo(Peticion: in  Petition_Type;
                            Campo: in ASU.Unbounded_String) return ASU.Unbounded_String is

       --funcion auxiliar, que nos devuelve el valor de un campo dado en un unbounded
      I:Integer:=1;
      Encontrado: Boolean:=FALSE;
      ValorDevuelto: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
    begin

          while (I<=Peticion.Fields_Array.Fields'Last) and (not Encontrado) loop
             if Peticion.Fields_Array.Fields(I).Name=Campo then
                Encontrado:=TRUE;
                ValorDevuelto:=Peticion.Fields_Array.Fields(i).Value;
             end if;
             I:=i+1;
          end loop;

      return ValorDevuelto;

    end DameValorCampo;

   ---------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------
    function ExisteCampoResp(Respuesta: in Reply_Type;
                             Campo: in ASU.Unbounded_String) return Boolean is
       --Funcion auxiliar, que nos dice si existe un campo en las cabeceras del tipo reply
       I: Integer:=1;
       Encontrado:Boolean:=FALSE;
    begin
       --Recorremos todos los posibles campos comparando...
       while (I<=Respuesta.Fields_Array.Fields'Last) and (not Encontrado) loop
         if Respuesta.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=True;
         end if;
         I:=i+1;
       end loop;
       --Y devolvemos el booleano
      return Encontrado;
    end ExisteCampoResp;

    --------------------------------------------------------------------------------------------




    --------------------------------------------------------------------------------------------
    function DameValorCampoResp(Respuesta: in  Reply_Type;
                                Campo: in ASU.Unbounded_String) return ASU.Unbounded_String is

       --funcion auxiliar, que nos devuelve el valor de un campo de una respuesta en un unbounded
      I:Integer:=1;
      Encontrado: Boolean:=FALSE;
      ValorDevuelto: ASU.Unbounded_String:=ASU.Null_Unbounded_String;
    begin

      while (I<=Respuesta.Fields_Array.Fields'Last) and (not Encontrado) loop
         if Respuesta.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=TRUE;
            ValorDevuelto:=Respuesta.Fields_Array.Fields(i).Value;
         end if;
         I:=i+1;
      end loop;

      return ValorDevuelto;

    end DameValorCampoResp;

------------------------------------------------------------------------------------------------------------



   function Build_Petition (Peticion: in Petition_Type) return ASU.Unbounded_String is
      --Recibe una peticion, y transforma su contenido en un unbounded string
      CadenaDevuelta: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
      I: Integer:=1;
   begin

      --Primero, agregamos el m�todo ::�����HAY QUE CUBRIR EL CASO DE UNKNOW, O SE ENCARGA ANALYZE"????
      if Peticion.Method=GET then
         CadenaDevuelta:= ASU.To_Unbounded_String("GET ");
      elsif Peticion.Method=HEAD then
         CadenaDevuelta:= ASU.To_Unbounded_String("HEAD ");
      elsif Peticion.Method=POST then
         CadenaDevuelta:= ASU.To_Unbounded_String("POST ");
      elsif Peticion.Method=PUT then
         CadenaDevuelta:= ASU.To_Unbounded_String("PUT ");
      end if;

      --Le agregamos el identificador de protocolo http://
      CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("http://");

      --Le agregamos el host y el path, sacando el valor del uri
      CadenaDevuelta:= CadenaDevuelta & Peticion.URI.Host & Peticion.Uri.Path & ASU.To_Unbounded_String(" ");

      --A continuacion le agregamos el tipo de protocolo, y un fin de linea
      if Peticion.Version=V10 then
         CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("HTTP/1.0" & Http_Common.End_Of_Header_Line);
      elsif Peticion.Version=V11 then
         CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("HTTP/1.1" & Http_Common.End_Of_Header_Line);
      end if;

      --Le agregamos el resto de campos
      if Peticion.Fields_Array.Fields'Last>0 then
         for I in 1..Peticion.Fields_Array.Fields'Last loop
            --Agregamos el nombre del campo
            CadenaDevuelta:=CadenaDevuelta & Peticion.Fields_Array.Fields(I).Name &
              ASU.To_Unbounded_String(": ");
            --Y su valor, y un end_of_header_line
            CadenaDevuelta:=CadenaDevuelta & Peticion.Fields_Array.Fields(I).Value &
              ASU.To_Unbounded_String(Http_Common.End_Of_Header_Line);
         end loop;
      end if;

      --y por �ltimo un campo connection close. Ya que cerraremos siempre la conexion con el remoto
      --(aqui metemos ya el End_of_Header
      CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("Connection: Close") & Http_Common.End_Of_Header;

      --Lo mostramos por pantalla (para la traza)
      Ada.Text_Io.Put_Line("Contenido de la peticion que vamos a enviar al servidor remoto : ");
      Ada.Text_Io.Put_Line("-----------------------------------------------------------------");
      Ada.Text_Io.Put_Line(ASU.To_String(CadenaDevuelta));


      --y la devolvemos
      return CadenaDevuelta;

   end Build_Petition;


   function Build_Reply (Reply_Remoto: in Reply_Type;
                         FinConexion:in Boolean;
                         FlagMaxConn: in Boolean) return ASU.Unbounded_String is
      --Construye un unbounded para devolver al cliente, a partir de la respuesta del host remoto
      --Le pasamos finConexion y flagMaxxConn  tb, porque el valor del campo Connection depende de lo que
      --hablamos antes con el cliente, �no de lo que nos respondio el remoto!

      I: Integer:=1;
      CadenaDevuelta: ASU.Unbounded_String:= ASU.Null_Unbounded_String;
   begin

      --Agregamos la primera l�nea de respuesta
      CadenaDevuelta:= Reply_Remoto.First_Line & ASU.To_Unbounded_String(Http_Common.End_Of_Header_Line);

      --Agregamos los campos
      for I in 1..Reply_Remoto.Fields_Array.Fields'Last loop
         --Agregamos el nombre del campo
         CadenaDevuelta:=CadenaDevuelta & Reply_Remoto.Fields_Array.Fields(I).Name &
           ASU.To_Unbounded_String(": ");
         --Y su valor, y un end_of_header_line
         CadenaDevuelta:=CadenaDevuelta & Reply_Remoto.Fields_Array.Fields(I).Value &
           ASU.To_Unbounded_String(Http_Common.End_Of_Header_Line);
      end loop;

      --Agregamos el campo Connection, cuyo valor depender� del booleano global, o de que hayamos
      -- realizado m�s de 5 conexiones ya

      if (FinConexion or FlagMaxConn) then
         CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("Connection: Close" & Http_Common.End_Of_Header);
      else
         CadenaDevuelta:= CadenaDevuelta & ASU.To_Unbounded_String("Connection: Keep-Alive" & Http_Common.End_Of_Header);
      end if;

      --Y por �ltimo, el contenido del cuerpo
      CadenaDevuelta:= CadenaDevuelta & Reply_Remoto.Reply_Body;

      --Lo mostramos por pantalla (para la traza)
      Ada.Text_Io.Put_Line("Contenido de la respuesta que vamos a enviar al cliente : ");
      Ada.Text_Io.Put_Line("-----------------------------------------------------------------");
      Ada.Text_Io.Put_Line(ASU.To_String(CadenaDevuelta));


      --y la devolvemos
      return CadenaDevuelta;
   end Build_Reply;


   --###############################################################################################



end Petition_Reply_Analysis;
