open Configurer_intf
open Layout_types


module Make  = struct

  include MakeConfigurer


  let set_choice_point f n lb lt fl cbt r =


  let conf = {
      fallback = f ;
      nesting_level = n ;
      linebuffer_count = lb ;
      linetext_length = lt ;
      flatten = fl;
      can_backtrack = cbt ;
      resume_at = r  ;
  } in conf

 end
