open Configurer_intf


module Make  = struct

  include MakeConfigurer


  let set_choice_point f n lb lt fl cbt r =


  let conf = {
      fallback = f ;
      nesting_Level = n ;
      linebuffer_count = lb ;
      linetext_length = lt ;
      flatten = fl;
      canback_track = cbt ;
      resume_at = r  ;
  } in conf

 end
