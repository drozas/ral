-- -------------------------------------------------------------
--´       Práctica de RAL (3º ITIS) : fase2
--        ------------------------------------------
-- ------------------------------------------------------------


package body Uri_analysis is

   procedure Inicializar_uri (Uri: in out URI_Type) is
   begin
      Uri.Protocol:=DEFAULT_PROTOCOL;
      Uri.Host:= DEFAULT_HOST;
      Uri.Port:= DEFAULT_PORT;
      Uri.Path:= DEFAULT_PATH;
   end Inicializar_uri;

   function Break_URI (cadena_entrada:ASU.Unbounded_String) return URI_Type is
      uri: URI_Type;
      pos1: integer:=0;
      pos2: integer:=0;
      Bad_Uri_Sintax: exception;
      CadenaAux: ASU.Unbounded_String;
   begin
      Inicializar_URI(Uri);

      if ASU.To_String(Cadena_Entrada)="" then
         Ada.Exceptions.Raise_exception(Bad_Uri_Syntax'Identity,"Error de sintaxis: esta vacia");
         else
            if ASU.To_String(cadena_entrada)(1..1)="/" then
               -- Si es del estilo : /...., solo habra que modificar el path
               uri.Path:=Cadena_entrada;
               return(Uri);

            elsif ASU.To_String(Cadena_Entrada)(1..7)="http://"  then
               --Recortamos la cadena
               CadenaAux:=ASU.To_Unbounded_String(ASU.To_String(Cadena_Entrada)(8..ASU.Length(Cadena_Entrada)));
               --Vamos a ver si hay puerto
               Pos1:= ASU.Index(CadenaAux,":");

               if Pos1/=0 then
                  --Si hay puerto...
                  --Hay que controlar...si hay puerto, pero no host
                  if Pos1>1 then
                     --Cogemos el host(si hay puerto-> tiene que haber host)
                     Uri.Host:=ASU.To_Unbounded_String(ASU.To_String(CAdenaAux)(1..(pos1-1)));
                     --Recortamos de nuevo,nos quedamos con a partir de :
                     CadenaAux:=ASU.To_Unbounded_String(ASU.To_String(CadenaAux)((pos1+1)..ASU.Length(CadenaAux)));
                     --Vemos si hay path
                     Pos2:=ASU.Index(CadenaAux,"/");
                     if Pos2/=0 then
                        --Si hay path, cogemos puerto, y path...
                        Uri.Port:=Natural'Value(Asu.To_String(CadenaAux)(1..pos2-1));
                        Uri.Path:=ASU.To_Unbounded_String(ASU.To_String(CadenaAux)(Pos2..ASU.Length(CadenaAux)));
                        return(Uri);
                     else
                        --Si no hay path, cogemos solo el puerto
                        Uri.Port:=Natural'Value(ASU.To_String(CadenaAux)(1..ASU.Length(CadenaAux)));
                        return(Uri);
                     end if;--Path1
                  else
                     Ada.Exceptions.Raise_exception(Bad_Uri_Syntax'Identity,"Error de sintaxis:hay puerto, pero no host");
                  end if;

               else
                  --Si no hay puerto: puede haber path o no
                  Pos2:=ASU.Index(CadenaAux,"/");
                  --Ada.Text_Io.Put_Line("mirando pos2= " & Integer'Image(Pos2));
                  --Tenemos que controlar si hay host
                  if Pos2/=0 then
                     --if ASU.To_String(CadenaAux)(1..pos2-1)="" then
                     if Pos2>1 then
                        --Si hay path, cogemos host y path por separado
                        Uri.Host:=ASU.To_Unbounded_String(ASU.To_String(CadenaAux)(1..pos2-1));
                        Uri.Path:=ASU.To_Unbounded_STring(Asu.To_String(CadenaAux)(Pos2..ASU.Length(CadenaAux)));
                        return(Uri);
                     else
                        Ada.Exceptions.Raise_exception(Bad_Uri_Syntax'Identity,"Error de sintaxis: hay path, pero no host");
                     end if;
                  else
                     --Si no hay path, solo cogemos el host
                     Uri.Host:=ASU.To_Unbounded_String(ASU.To_String(CadenaAux)(1..ASU.Length(CadenaAux)));
                     return(uri);
                  end if;--Path2

               end if; --Ver puerto
            else
               Ada.Exceptions.Raise_exception(Bad_Uri_Syntax'Identity,"Error de sintaxis: ni /, ni http://");
            end if;
      end if;


   end Break_URI;


end URI_Analysis;
