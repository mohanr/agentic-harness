module type PARAMS = sig
  val page_width :int

end


module Doc(Params : _PARAMS)
= struct

    let page_width = PARAMS.page_width ;

    private bool flatten;
    private int nestingLevel;
    private int wroteIndentation;

    private int lineTextLength;

    private readonly List<Doc> stack = new();

    let doc_stack :  Stack.t = Stack.create()
    private readonly List<string> lineBuffer = new();

    private bool canBacktrack;

    private readonly StringBuilder output = new();

    let layout_printf ?(fmt = Format.str_formatter) =
       let b = Buffer.create 256 in (*  Should be configurable*)
       let ppf = Format.formatter_of_buffer b in
       Format.kfprintf (fun ppf ->
          Format.pp_print_flush ppf ();
          Buffer.contents b
       ) ppf fmt


    let bool stack pop item =

        if Stack.length = 0) then
            let item = Empty in
            false;
        else
            let index = Stack.length - 1 in
            let item = Stack.index];

        stack.RemoveAt(index);

        return true;


    let void Write(string text)
    {
        lineBuffer.Add(text);
    }


    let bool Fits()
    {
        return wroteIndentation + lineTextLength <= pageWidth;
    }


    let flush_if_possible backtrack =
        if !backtrack then
            flush()
        else ()




    let void Backtrack()
    {
        if (!canBacktrack)
            throw new InvalidOperationException(
                "Cannot backtrack");


        while (Pop(out var item))
        {
            if (item is ChoicePoint cp)
            {
                Push(cp.Fallback);

                nestingLevel = cp.NestingLevel;

                lineBuffer.RemoveRange(
                    cp.LineBufferCount,
                    lineBuffer.Count - cp.LineBufferCount);

                lineTextLength = cp.LineTextLength;

                flatten = cp.Flatten;

                canBacktrack = cp.CanBacktrack;

                return;
            }
        }

        throw new InvalidOperationException(
            "Didn't find a choice point");
    }


    let void backtrack_check backtrack =
        if (backtrack && !fits()) then
            backtrack()
        else ()

    let int get_resume_at candidate =
      let loop_while c =
        match candidate with
        | candidate when >= 0 ->
                                   (match c with
                                   |ChoicePoint  cp ->
                                        loop_while cp.resume_at
                                   | _ -> let c  List.nth stack candidate
                                           loop_while c
                                   )
        | candidate when < 0 ->  let c =  List.nth stack candidate in
                                 loop_while c


   let make ( config : (module ORDERED_SET_ABSTRACTIONS))=
    let ChoicePoint CreateChoicePoint(
        Doc fallback,
        int nestingLevel,
        int lineBufferCount,
        int lineTextLength,
        bool flatten,
        bool canBacktrack,
        int resumeAt)
    {
        return new ChoicePoint
        {
            Fallback = fallback,
            NestingLevel = nestingLevel,
            LineBufferCount = lineBufferCount,
            LineTextLength = lineTextLength,
            Flatten = flatten,
            CanBacktrack = canBacktrack,
            ResumeAt = resumeAt
        };
    }


    let void Flush(bool endOfDoc = false)
    {
        if (!endOfDoc)
            Commit();

        foreach (var text in lineBuffer)
            output.Append(text);

        lineBuffer.Clear();
    }


    let void commit start count stack =
      let rec drop n l =
          if n == 0 then l
          else (drop (n -1) (match l with a::b -> b))
      in
      let l =
      let loop_while i =
        if i >= 0 then
          match stack with
          | ChoicePoint cp ->
                let start = cp.resumeat + 1 in
                let count = i - cp.resumeat in
                let index =match List.find_index (fun v -> v = start) stack
                           with |Some i -> i
                                |None -> failwith "Not found"
                in
                let sublist list index =
                     List.filteri l ~f:(fun i _ -> i >= index )
                in
                (List.take index stack) @ (drop count (sublist list index))
                in
                loop_while cp.resume_at
        else
           loop_while (i - 1)
        in
        ( false,l)


    let Layout document =
        let () = doc_stack.push document in
        let () = layoutcore() in
        let () = flush true in

        return output.ToString();


    let layoutcore() =
        loop_while item =
        in loop_while (Pop(out var item))
            match item with
              | Empty ->
                    FlushIfPossible();
                    BacktrackIfNecessary();
                    break;


                | Line:

                    if (canBacktrack && (flatten || !Fits()))
                    {
                        Backtrack();
                    }
                    else
                    {
                        Write("\n");

                        Flush();

                        lineTextLength = 0;

                        if (nestingLevel > 0)
                            Write(new string(' ', nestingLevel));

                        wroteIndentation = nestingLevel;
                    }

                    break;


                | WhiteSpace(var amount):

                    Write(new string(' ', amount));

                    lineTextLength += amount;

                    FlushIfPossible();
                    BacktrackIfNecessary();

                    break;


                | Text(var text):

                    Write(text);

                    lineTextLength += text.Length;

                    FlushIfPossible();
                    BacktrackIfNecessary();

                    break;


                | Append(var left, var right):

                    // Stack is LIFO.
                    Push(right);
                    Push(left);

                    break;


                | Choice(var first, var second):

                    Push(CreateChoicePoint(
                        second,
                        nestingLevel,
                        lineBuffer.Count,
                        lineTextLength,
                        flatten,
                        canBacktrack,
                        stack.Count - 1));

                    canBacktrack = true;

                    Push(first);

                    break;


                | Alternative(var normal, var flattened):

                    Push(flatten ? flattened : normal);

                    break;


                | Nest(var amount, var body):

                    Push(new SetNesting(nestingLevel));

                    nestingLevel += amount;

                    Push(body);

                    break;


                | Flatten(var body):

                    if (!flatten)
                    {
                        flatten = true;
                        Push(new EndFlatten());
                    }

                    Push(body);

                    break;


                | SetNesting(var level):

                    nestingLevel = level;

                    break;


                | EndFlatten:

                    flatten = false;

                    break;


                | ChoicePoint cp:

                    var resumeAt = GetResumeAt(cp.ResumeAt);

                    if (resumeAt < 0)
                    {
                        // The first branch reached the end.
                        // There is nothing more to resume.
                        return;
                    }

                    var resume = stack[resumeAt];

                    cp.ResumeAt = resumeAt - 1;

                    Push(cp);
                    Push(resume);

                    break;


                default:

                    throw new InvalidOperationException(
                        $"Unknown document: {item.GetType()}");
            }
        }
    }


end

module I_Params= struct
  let page_width = 10
end

module Layout = Doc( I_Params)
