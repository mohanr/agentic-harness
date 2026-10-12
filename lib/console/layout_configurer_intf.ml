open Base

module MakeConfigurer = struct

type choice_point = {
    fallback : bool;
    nesting_level : int;
    linebuffer_count : int;
    linetext_length : int;
    flatten : bool;
    can_backtrack : bool;
    resume_at : int
  }
[@@deriving show ,compare, sexp]

end

module type Configurer=
sig

  include module type of MakeConfigurer
  val config : choice_point

end



module type MAKER = Configurer
module type Intf = sig
  module Make : MAKER

end
