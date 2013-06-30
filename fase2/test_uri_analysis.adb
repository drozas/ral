with Ada.Text_IO;
with Ada.Strings;
with Ada.Strings.Unbounded;
with Ada.Exceptions;

with URI_Analysis;

use Ada.Strings.Unbounded;

procedure Test_URI_Analysis is

    package Unbounded renames Ada.Strings.Unbounded;
    package Exceptions renames Ada.Exceptions;
    

    URIS        :   array(1..6) of Unbounded.Unbounded_String;  -- URIs to be successfully parsed.
    Target_URIS :   array(1..6) of URI_Analysis.URI_Type;       -- To compare with the results of parsing the URIs in previous array.
    
    Wrong_URIS  :   array(1..7) of Unbounded.Unbounded_String;  -- All this URIs must raise a Bad_URI_Syntax exception when parsed.
    
    Analized_URI    :   URI_Analysis.URI_Type;

    
    ---------------------------------------------------------------------------------------------------------------
    -- Method to compare URI_Type objects. An exception is raised if the two of them do not have the same values.--
    ---------------------------------------------------------------------------------------------------------------
    procedure Compare(  URI1    :   in URI_Analysis.URI_Type;
                        URI2    :   in URI_Analysis.URI_Type) is
        Bad_Parsing :   exception;
    begin
        
        -- Checking protocol
        if URI1.Protocol /= URI2.Protocol then
            Exceptions.Raise_Exception( Bad_Parsing'Identity, "Protocol error, should be " & Unbounded.To_String(URI2.Protocol) 
                                        & ", not " & Unbounded.To_String(URI1.Protocol));
        end if;
        
        -- Checking host
        if URI1.Host /= URI2.Host then
            Exceptions.Raise_Exception( Bad_Parsing'Identity, "Host error, should be " & Unbounded.To_String(URI2.Host)
                                        & ", not " & Unbounded.To_String(URI1.Host));
        end if;

        -- Checking port
        if URI1.Port /= URI2.Port then
            Exceptions.Raise_Exception( Bad_Parsing'Identity, "Port error, should be " & URI2.Port'Img
                                        & ", not " & URI1.Port'Img);
        end if;
        
        -- Checking path
        if URI1.Path /= URI2.Path then
            Exceptions.Raise_Exception( Bad_Parsing'Identity, "Path error, should be " & Unbounded.To_String(URI2.Path)
                                        & ", not " & Unbounded.To_String(URI1.Path));
        end if;
        
    end Compare;
    ---------------------------------------------------------------------------------------------------------------
    

begin

    ---------------------
    -- Setting URIs tests
    ---------------------
    URIS(1) := Unbounded.To_Unbounded_String("http://www.host:900/path1/path");
    Target_URIS(1).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(1).Host     := Unbounded.To_Unbounded_String("www.host");
    Target_URIS(1).Port     := 900;
    Target_URIS(1).Path     := Unbounded.To_Unbounded_String("/path1/path"); 
    
    URIS(2) := Unbounded.To_Unbounded_String("http://www.host/path1/path");
    Target_URIS(2).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(2).Host     := Unbounded.To_Unbounded_String("www.host");
    Target_URIS(2).Port     := URI_Analysis.DEFAULT_PORT;
    Target_URIS(2).Path     := Unbounded.To_Unbounded_String("/path1/path"); 
    
    --URIS(3) := Unbounded.To_Unbounded_String("www.host/path1/path");
    --Target_URIS(3).Protocol := URI_Analysis.HTTP_PROTOCOL;
    --Target_URIS(3).Host     := Unbounded.To_Unbounded_String("www.host");
    --Target_URIS(3).Port     := URI_Analysis.DEFAULT_PORT;
    --Target_URIS(3).Path     := Unbounded.To_Unbounded_String("/path1/path"); 
    
    --URIS(4) := Unbounded.To_Unbounded_String("www.uri");
    --Target_URIS(4).Protocol := URI_Analysis.HTTP_PROTOCOL;
    --Target_URIS(4).Host     := Unbounded.To_Unbounded_String("www.uri");
    --Target_URIS(4).Port     := URI_Analysis.DEFAULT_PORT;
    --Target_URIS(4).Path     := URI_Analysis.DEFAULT_PATH;
    
    URIS(3) := Unbounded.To_Unbounded_String("/path1/path");
    Target_URIS(3).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(3).Host     := URI_Analysis.DEFAULT_HOST;
    Target_URIS(3).Port     := URI_Analysis.DEFAULT_PORT;
    Target_URIS(3).Path     := Unbounded.To_Unbounded_String("/path1/path"); 

    URIS(4) := Unbounded.To_Unbounded_String("/");
    Target_URIS(4).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(4).Host     := URI_Analysis.DEFAULT_HOST;
    Target_URIS(4).Port     := URI_Analysis.DEFAULT_PORT;
    Target_URIS(4).Path     := URI_Analysis.DEFAULT_PATH; 

    URIS(5) := Unbounded.To_Unbounded_String("http://www.host:700");
    Target_URIS(5).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(5).Host     := Unbounded.To_Unbounded_String("www.host");
    Target_URIS(5).Port     := 700;
    Target_URIS(5).Path     := URI_Analysis.DEFAULT_PATH;

    URIS(6) := Unbounded.To_Unbounded_String("http://www.host");
    Target_URIS(6).Protocol := URI_Analysis.HTTP_PROTOCOL;
    Target_URIS(6).Host     := Unbounded.To_Unbounded_String("www.host");
    Target_URIS(6).Port     := URI_Analysis.DEFAULT_PORT;
    Target_URIS(6).Path     := URI_Analysis.DEFAULT_PATH;


    ---------------------------
    -- Setting wrong URIs tests
    ---------------------------
    Wrong_URIS(1) := Unbounded.To_Unbounded_String("http:///path");             -- Where is the host?
    Wrong_URIS(2) := Unbounded.To_Unbounded_String("http://:700");              -- Where is the host?
    Wrong_URIS(3) := Unbounded.To_Unbounded_String("ftp://www.uri.com:700");    -- Only http protocol is accepted.
    Wrong_URIS(4) := Unbounded.To_Unbounded_String("://www.uri.com:700");       -- Where is the protocol?.
    Wrong_URIS(5) := Unbounded.To_Unbounded_String("www.uri.com:700/path");     -- Where is the protocol?.
    Wrong_URIS(6) := Unbounded.To_Unbounded_String(":700/path");                -- Where is the protocol?.
    Wrong_URIS(7) := Unbounded.To_Unbounded_String("");                         -- Where is... everything?.

    
    -----------------------
    -- Executing URIs tests 
    -----------------------
    for Test in URIS'Range loop
    
        Ada.Text_IO.New_Line;
        Ada.Text_IO.Put_Line("Parsing URI " & Unbounded.To_String(URIS(Test)));
        Analized_URI := URI_Analysis.Break_URI(URIS(Test));
    
        -- Checking result, an exception is raised if the parsed and expected URIS differ.
        Compare(Analized_URI, Target_URIS(Test));
        Ada.Text_IO.New_Line;
        Ada.Text_IO.Put_Line("URI successfully parsed");
        Ada.Text_IO.Put_Line("---------------------------------------------------------");
    
    end loop;


    -------------------------------------------------------------------------------------------------
    -- Executing wrong URIs tests (a Bad_URI_Syntax exception must be raised by the Break_URI method)
    -------------------------------------------------------------------------------------------------
    for Test in Wrong_URIS'Range loop
    
        begin
            
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line("Parsing URI " & Unbounded.To_String(Wrong_URIS(Test)));
            Analized_URI := URI_Analysis.Break_URI(Wrong_URIS(Test));
    
            -- Never should get here
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line("Non exception raised for URI " & Unbounded.To_String(Wrong_URIS(Test)) & ", error!");
            return;

        exception when Exception_Instance : URI_Analysis.Bad_URI_Syntax =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line("Exception caught");
            Ada.Text_IO.Put_Line(Exceptions.Exception_Information(Exception_Instance));
            Ada.Text_IO.Put_Line("It is ok");
            Ada.Text_IO.Put_Line("---------------------------------------------------------");
        end;
    
    end loop;
    

    ----------------------------------
    -- All tests executed successfully
    ----------------------------------
    Ada.Text_IO.New_Line;
    Ada.Text_IO.Put_Line("All URIS checked, module -SEEMS- to work fine.");
    Ada.Text_IO.New_Line;


end Test_URI_Analysis;
