open Types

module type Holder = sig

   type 'text representation= {

     self : 'text ;

     text_length : 'text -> int
   }
   type text = Text : 'text representation-> text

type textholder  = {

    data : text;                (*Existential  *)

    scroll : location

}

    val make : string -> textholder       (* No embellishments like style for now *)
end
module Textholder = struct

(* An existential is an abstraction of data representation *)
type 'text representation= {

  self : 'text ;

  text_length : 'text -> int
}
type text = Text : 'text representation-> text

let make_string_text() =
  Text {
    self = String.empty;
    text_length = String.length;
  }

let text_length (Text {text_length; self}) = text_length self

type textholder  = {

    data : text;                (*Existential  *)

    scroll : location           (* Scroll feature is not implemented *)

}

    let make text =

      let location =
               {

                x = 0;

                y = 0

               } in
      {data =  text; scroll =
                  location  }       (* No embellishments like style for now *)

    let scroll offset =
        {
            x =  fst offset;
            y =  snd offset
        }

let render data  =
  {
    data = data;
    scroll = {x = 0; y = 0}     (*  Test location*)
  }

end
