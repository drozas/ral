
package body http_Aux is

   function CoincideCampo(peticion: in Petition_Type;
                          campo: in ASU.Unbounded_String;
                          Valor:in ASU.Unbounded_String) return boolean is
      --Le pasamos un campo, y un posible valor, y nos devuelve un booleano
      --diciendo si el valor es igual
      i: integer:=1;
      CampoEncontrado: boolean:= FALSE;
      IgualValor:Boolean:=FALSE;
   begin

      --Recorremos todos los nombres de campo posible
      while i<=Peticion.Number_fields and (not CampoEncontrado) loop
        --Si lo encontramos, miramos si coincide el valor..
                if peticion.fields_Array.Fields(i).Name = Campo then
            CampoEncontrado:=TRUE;

            if Peticion.Fields_Array.Fields(i).Value=valor then
               IgualValor:=TRUE;
            end if;
         end if;
         i:=i+1;
      end loop;
          --Devolvemos el booleano que nos dice si el valor coincidió.
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
          while (I<=Peticion.Number_Fields) and (not Encontrado) loop
         if Peticion.Fields_Array.Fields(I).Name=Campo then
            Encontrado:=True;
         end if;
         I:=i+1;
      end loop;
      --Y devolvemos el booleano
      return Encontrado;
   end ExisteCampo;

-----------------------------------------------------------------------------------------
end http_Aux;
