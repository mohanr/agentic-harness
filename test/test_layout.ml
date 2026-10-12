
let%expect_test "Merge two documents"=
   let r doc =
     Choice(Append(Empty ,
                    Text "hello"
                   ),
                   (Empty ,Space),
                   (Empty ,Text "world" )

    ),
    Choice((Append(Empty ,
                    Text "hello"
                   ),
                   (Empty ,Space),
                   (Empty ,Text "world" )),
           (Append(Empty ,
                    Text "hello"
                   ),
                   (Empty ,Space),
                   (Empty ,Text "world" ))
          )


        Console.WriteLine(
            new LayoutEngine(20).Layout(doc));

        Console.WriteLine(
            new LayoutEngine(8).Layout(doc));
        [%expect {| Text 2 |}]
