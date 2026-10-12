open Buffer
open Types


module MockDriver =
struct

type t = test_driver

module Make( Config : Configurer_intf.Configurer)
           ( Buffer : BUFFERMAKER)= struct


    let empty_buffer ()=
    let module B =   Buffer.Make(Config) in
    let config= Config.set_size 50 50 in (* Should be mutable to set and get. *)
                                            (* But now it is not set before we call *)
                                            (* 'Make' *)
      let nb =
      {
            pos = (config.width , config.height)
      }
      in nb

end
end
