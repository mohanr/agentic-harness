open Layout
open Layout_types

module I_Params1= struct
  let page_width = 10           (* Example  *)
end

module Layout = Docu( I_Params1)


let%expect_test "hello world"=
    let type1 = Alternative(Line, (Text " ")) in
    let formatted_doc = Append(Text "hello" , Append(type1 ,( Text "world"))) in
    Printf.printf "%s" (Layout.layout (Doc formatted_doc ));
    [%expect {|
      (Doc
       (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world))))

      (Doc (Text hello))
      hello
      |}]


module I_Params2 = struct
  let page_width = 11           (* Example  *)
end

module Layout1 = Docu( I_Params2 )

let%expect_test "Fits test"=
    let group text = Choice(Flatten(text ), text ) in
    let type1 = Alternative(Line, (Text " ")) in
    let formatted_doc = Append(Text "hello" , Append(type1 ,( Text "world"))) in
    Printf.printf "%s" (Layout1.layout (Doc (group formatted_doc )));
    [%expect {|
      (Doc
       (Choice
        (Flatten
         (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world))))
        (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world)))))

      (Doc
       (Flatten
        (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world)))))

      (Doc
       (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world))))

      (Doc (Text hello))
      (Doc
                          (Append (Text hello)
                           (Append (Alternative Line (Text " ")) (Text world))))

      (Doc (Text hello))
      hellohello
      |}]

let%expect_test "Break test"=
    let group text = Choice(Flatten(text ), text ) in
    let type1 = Alternative(Line, (Text " ")) in
    let formatted_doc = Append(Text "hello" , Append(type1 ,( Text "world"))) in
    Printf.printf "%s" (Layout1.layout (Doc (group formatted_doc )));
    [%expect {|
      (Doc
       (Choice
        (Flatten
         (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world))))
        (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world)))))

      (Doc
       (Flatten
        (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world)))))

      (Doc
       (Append (Text hello) (Append (Alternative Line (Text " ")) (Text world))))

      (Doc (Text hello))
      (Doc
                          (Append (Text hello)
                           (Append (Alternative Line (Text " ")) (Text world))))

      (Doc (Text hello))
      hellohellohellohello
      |}]
