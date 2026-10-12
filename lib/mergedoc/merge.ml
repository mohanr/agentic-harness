[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S
  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t


  module Reader : sig
    type array_t
    type builder_array_t
    type pointer_t = ro MessageWrapper.Slice.t option
    val of_pointer : pointer_t -> 'a reader_t
    module AgentU : sig
      type struct_t = [`AgentU_a977e52101cb24de]
      type t = struct_t reader_t
      module Message : sig
        type struct_t = [`Message_8eef0c28ea11163d]
        type t = struct_t reader_t
        type unnamed_union_t =
          | Someagent of string
          | Noneagent
          | Undefined of int
        val get : t -> unnamed_union_t
        val of_message : 'cap message_t -> t
        val of_builder : struct_t builder_t -> t
      end
      val message_get : t -> Message.t
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module SeqU : sig
      type struct_t = [`SeqU_e8839c796c0dbfd2]
      type t = struct_t reader_t
      module Message : sig
        type struct_t = [`Message_8f90a95be910c25d]
        type t = struct_t reader_t
        type unnamed_union_t =
          | Someseq of int
          | Noneseq
          | Undefined of int
        val get : t -> unnamed_union_t
        val of_message : 'cap message_t -> t
        val of_builder : struct_t builder_t -> t
      end
      val message_get : t -> Message.t
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module Identity : sig
      type struct_t = [`Identity_9f86b55c0cb15216]
      type t = struct_t reader_t
      val has_agent : t -> bool
      val agent_get : t -> AgentU.t
      val agent_get_pipelined : struct_t MessageWrapper.StructRef.t -> AgentU.struct_t MessageWrapper.StructRef.t
      val has_seq : t -> bool
      val seq_get : t -> SeqU.t
      val seq_get_pipelined : struct_t MessageWrapper.StructRef.t -> SeqU.struct_t MessageWrapper.StructRef.t
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module IdentityU : sig
      type struct_t = [`IdentityU_d092f1b45afbde2a]
      type t = struct_t reader_t
      module Message : sig
        type struct_t = [`Message_c569022e0ac5e919]
        type t = struct_t reader_t
        type unnamed_union_t =
          | Someidentity of Identity.t
          | Noneidentity
          | Undefined of int
        val get : t -> unnamed_union_t
        val of_message : 'cap message_t -> t
        val of_builder : struct_t builder_t -> t
      end
      val message_get : t -> Message.t
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module Ident : sig
      type struct_t = [`Ident_c1e4df594ee0d9e2]
      type t = struct_t reader_t
      val has_agent : t -> bool
      val agent_get : t -> string
      val seq_get : t -> int
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module Item : sig
      type struct_t = [`Item_cd0899f5127dcb10]
      type t = struct_t reader_t
      val has_content : t -> bool
      val content_get : t -> string
      val has_id : t -> bool
      val id_get : t -> Ident.t
      val id_get_pipelined : struct_t MessageWrapper.StructRef.t -> Ident.struct_t MessageWrapper.StructRef.t
      val has_originleft : t -> bool
      val originleft_get : t -> IdentityU.t
      val originleft_get_pipelined : struct_t MessageWrapper.StructRef.t -> IdentityU.struct_t MessageWrapper.StructRef.t
      val has_originright : t -> bool
      val originright_get : t -> IdentityU.t
      val originright_get_pipelined : struct_t MessageWrapper.StructRef.t -> IdentityU.struct_t MessageWrapper.StructRef.t
      val deleted_get : t -> bool
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module VersionTuple : sig
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t reader_t
      val has_key : t -> bool
      val key_get : t -> string
      val value_get : t -> int
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc : sig
        module Params : sig
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t reader_t
          val has_itemlist : t -> bool
          val itemlist_get : t -> (ro, Item.t, array_t) Capnp.Array.t
          val itemlist_get_list : t -> Item.t list
          val itemlist_get_array : t -> Item.t array
          val has_doccontent : t -> bool
          val doccontent_get : t -> (ro, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val of_message : 'cap message_t -> t
          val of_builder : struct_t builder_t -> t
        end
        module Results : sig
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t reader_t
          val has_itemlist : t -> bool
          val itemlist_get : t -> (ro, Item.t, array_t) Capnp.Array.t
          val itemlist_get_list : t -> Item.t list
          val itemlist_get_array : t -> Item.t array
          val has_doccontent : t -> bool
          val doccontent_get : t -> (ro, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val of_message : 'cap message_t -> t
          val of_builder : struct_t builder_t -> t
        end
      end
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t
    module AgentU : sig
      type struct_t = [`AgentU_a977e52101cb24de]
      type t = struct_t builder_t
      module Message : sig
        type struct_t = [`Message_8eef0c28ea11163d]
        type t = struct_t builder_t
        type unnamed_union_t =
          | Someagent of string
          | Noneagent
          | Undefined of int
        val get : t -> unnamed_union_t
        val someagent_set : t -> string -> unit
        val noneagent_set : t -> unit
        val of_message : rw message_t -> t
        val to_message : t -> rw message_t
        val to_reader : t -> struct_t reader_t
        val init_root : ?message_size:int -> unit -> t
        val init_pointer : pointer_t -> t
      end
      val message_get : t -> Message.t
      val message_init : t -> Message.t
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module SeqU : sig
      type struct_t = [`SeqU_e8839c796c0dbfd2]
      type t = struct_t builder_t
      module Message : sig
        type struct_t = [`Message_8f90a95be910c25d]
        type t = struct_t builder_t
        type unnamed_union_t =
          | Someseq of int
          | Noneseq
          | Undefined of int
        val get : t -> unnamed_union_t
        val someseq_set_exn : t -> int -> unit
        val noneseq_set : t -> unit
        val of_message : rw message_t -> t
        val to_message : t -> rw message_t
        val to_reader : t -> struct_t reader_t
        val init_root : ?message_size:int -> unit -> t
        val init_pointer : pointer_t -> t
      end
      val message_get : t -> Message.t
      val message_init : t -> Message.t
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module Identity : sig
      type struct_t = [`Identity_9f86b55c0cb15216]
      type t = struct_t builder_t
      val has_agent : t -> bool
      val agent_get : t -> AgentU.t
      val agent_set_reader : t -> AgentU.struct_t reader_t -> AgentU.t
      val agent_set_builder : t -> AgentU.t -> AgentU.t
      val agent_init : t -> AgentU.t
      val has_seq : t -> bool
      val seq_get : t -> SeqU.t
      val seq_set_reader : t -> SeqU.struct_t reader_t -> SeqU.t
      val seq_set_builder : t -> SeqU.t -> SeqU.t
      val seq_init : t -> SeqU.t
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module IdentityU : sig
      type struct_t = [`IdentityU_d092f1b45afbde2a]
      type t = struct_t builder_t
      module Message : sig
        type struct_t = [`Message_c569022e0ac5e919]
        type t = struct_t builder_t
        type unnamed_union_t =
          | Someidentity of Identity.t
          | Noneidentity
          | Undefined of int
        val get : t -> unnamed_union_t
        val someidentity_set_reader : t -> Identity.struct_t reader_t -> Identity.t
        val someidentity_set_builder : t -> Identity.t -> Identity.t
        val someidentity_init : t -> Identity.t
        val noneidentity_set : t -> unit
        val of_message : rw message_t -> t
        val to_message : t -> rw message_t
        val to_reader : t -> struct_t reader_t
        val init_root : ?message_size:int -> unit -> t
        val init_pointer : pointer_t -> t
      end
      val message_get : t -> Message.t
      val message_init : t -> Message.t
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module Ident : sig
      type struct_t = [`Ident_c1e4df594ee0d9e2]
      type t = struct_t builder_t
      val has_agent : t -> bool
      val agent_get : t -> string
      val agent_set : t -> string -> unit
      val seq_get : t -> int
      val seq_set_exn : t -> int -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module Item : sig
      type struct_t = [`Item_cd0899f5127dcb10]
      type t = struct_t builder_t
      val has_content : t -> bool
      val content_get : t -> string
      val content_set : t -> string -> unit
      val has_id : t -> bool
      val id_get : t -> Ident.t
      val id_set_reader : t -> Ident.struct_t reader_t -> Ident.t
      val id_set_builder : t -> Ident.t -> Ident.t
      val id_init : t -> Ident.t
      val has_originleft : t -> bool
      val originleft_get : t -> IdentityU.t
      val originleft_set_reader : t -> IdentityU.struct_t reader_t -> IdentityU.t
      val originleft_set_builder : t -> IdentityU.t -> IdentityU.t
      val originleft_init : t -> IdentityU.t
      val has_originright : t -> bool
      val originright_get : t -> IdentityU.t
      val originright_set_reader : t -> IdentityU.struct_t reader_t -> IdentityU.t
      val originright_set_builder : t -> IdentityU.t -> IdentityU.t
      val originright_init : t -> IdentityU.t
      val deleted_get : t -> bool
      val deleted_set : t -> bool -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module VersionTuple : sig
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t builder_t
      val has_key : t -> bool
      val key_get : t -> string
      val key_set : t -> string -> unit
      val value_get : t -> int
      val value_set_exn : t -> int -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc : sig
        module Params : sig
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t builder_t
          val has_itemlist : t -> bool
          val itemlist_get : t -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_get_list : t -> Item.t list
          val itemlist_get_array : t -> Item.t array
          val itemlist_set : t -> (rw, Item.t, array_t) Capnp.Array.t -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_set_list : t -> Item.t list -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_set_array : t -> Item.t array -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_init : t -> int -> (rw, Item.t, array_t) Capnp.Array.t
          val has_doccontent : t -> bool
          val doccontent_get : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val doccontent_set : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_list : t -> VersionTuple.t list -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_array : t -> VersionTuple.t array -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_init : t -> int -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val of_message : rw message_t -> t
          val to_message : t -> rw message_t
          val to_reader : t -> struct_t reader_t
          val init_root : ?message_size:int -> unit -> t
          val init_pointer : pointer_t -> t
        end
        module Results : sig
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t builder_t
          val has_itemlist : t -> bool
          val itemlist_get : t -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_get_list : t -> Item.t list
          val itemlist_get_array : t -> Item.t array
          val itemlist_set : t -> (rw, Item.t, array_t) Capnp.Array.t -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_set_list : t -> Item.t list -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_set_array : t -> Item.t array -> (rw, Item.t, array_t) Capnp.Array.t
          val itemlist_init : t -> int -> (rw, Item.t, array_t) Capnp.Array.t
          val has_doccontent : t -> bool
          val doccontent_get : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val doccontent_set : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_list : t -> VersionTuple.t list -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_array : t -> VersionTuple.t array -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_init : t -> int -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val of_message : rw message_t -> t
          val to_message : t -> rw message_t
          val to_reader : t -> struct_t reader_t
          val init_root : ?message_size:int -> unit -> t
          val init_pointer : pointer_t -> t
        end
      end
    end
  end
end

module MakeRPC(MessageWrapper : Capnp.RPC.S) = struct
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t
  module CamlBytes = Bytes
  module DefaultsMessage_ = Capnp.BytesMessage

  let _builder_defaults_message =
    let message_segments = [
      Bytes.unsafe_of_string "\
      ";
    ] in
    DefaultsMessage_.Message.readonly
      (DefaultsMessage_.Message.of_storage message_segments)

  let invalid_msg = Capnp.Message.invalid_msg

  include Capnp.Runtime.BuilderInc.Make(MessageWrapper)

  type 'cap message_t = 'cap MessageWrapper.Message.t

  module DefaultsCopier_ =
    Capnp.Runtime.BuilderOps.Make(Capnp.BytesMessage)(MessageWrapper)

  let _reader_defaults_message =
    MessageWrapper.Message.create
      (DefaultsMessage_.Message.total_size _builder_defaults_message)


  module Reader = struct
    type array_t = ro MessageWrapper.ListStorage.t
    type builder_array_t = rw MessageWrapper.ListStorage.t
    type pointer_t = ro MessageWrapper.Slice.t option
    let of_pointer = RA_.deref_opt_struct_pointer

    module AgentU = struct
      type struct_t = [`AgentU_a977e52101cb24de]
      type t = struct_t reader_t
      module Message = struct
        type struct_t = [`Message_8eef0c28ea11163d]
        type t = struct_t reader_t
        let has_someagent x =
          RA_.has_field x 0
        let someagent_get x =
          RA_.get_text ~default:"" x 0
        let noneagent_get x = ()
        type unnamed_union_t =
          | Someagent of string
          | Noneagent
          | Undefined of int
        let get x =
          match RA_.get_uint16 ~default:0 x 0 with
          | 0 -> Someagent (someagent_get x)
          | 1 -> Noneagent
          | v -> Undefined v
        let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
        let of_builder x = Some (RA_.StructStorage.readonly x)
      end
      let message_get x = RA_.cast_struct x
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module SeqU = struct
      type struct_t = [`SeqU_e8839c796c0dbfd2]
      type t = struct_t reader_t
      module Message = struct
        type struct_t = [`Message_8f90a95be910c25d]
        type t = struct_t reader_t
        let someseq_get x =
          RA_.get_int16 ~default:(0) x 0
        let noneseq_get x = ()
        type unnamed_union_t =
          | Someseq of int
          | Noneseq
          | Undefined of int
        let get x =
          match RA_.get_uint16 ~default:0 x 2 with
          | 0 -> Someseq (someseq_get x)
          | 1 -> Noneseq
          | v -> Undefined v
        let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
        let of_builder x = Some (RA_.StructStorage.readonly x)
      end
      let message_get x = RA_.cast_struct x
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module Identity = struct
      type struct_t = [`Identity_9f86b55c0cb15216]
      type t = struct_t reader_t
      let has_agent x =
        RA_.has_field x 0
      let agent_get x =
        RA_.get_struct x 0
      let agent_get_pipelined x =
        MessageWrapper.Untyped.struct_field x 0
      let has_seq x =
        RA_.has_field x 1
      let seq_get x =
        RA_.get_struct x 1
      let seq_get_pipelined x =
        MessageWrapper.Untyped.struct_field x 1
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module IdentityU = struct
      type struct_t = [`IdentityU_d092f1b45afbde2a]
      type t = struct_t reader_t
      module Message = struct
        type struct_t = [`Message_c569022e0ac5e919]
        type t = struct_t reader_t
        let has_someidentity x =
          RA_.has_field x 0
        let someidentity_get x =
          RA_.get_struct x 0
        let someidentity_get_pipelined x =
          MessageWrapper.Untyped.struct_field x 0
        let noneidentity_get x = ()
        type unnamed_union_t =
          | Someidentity of Identity.t
          | Noneidentity
          | Undefined of int
        let get x =
          match RA_.get_uint16 ~default:0 x 0 with
          | 0 -> Someidentity (someidentity_get x)
          | 1 -> Noneidentity
          | v -> Undefined v
        let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
        let of_builder x = Some (RA_.StructStorage.readonly x)
      end
      let message_get x = RA_.cast_struct x
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module Ident = struct
      type struct_t = [`Ident_c1e4df594ee0d9e2]
      type t = struct_t reader_t
      let has_agent x =
        RA_.has_field x 0
      let agent_get x =
        RA_.get_text ~default:"" x 0
      let seq_get x =
        RA_.get_int16 ~default:(0) x 0
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module Item = struct
      type struct_t = [`Item_cd0899f5127dcb10]
      type t = struct_t reader_t
      let has_content x =
        RA_.has_field x 0
      let content_get x =
        RA_.get_text ~default:"" x 0
      let has_id x =
        RA_.has_field x 1
      let id_get x =
        RA_.get_struct x 1
      let id_get_pipelined x =
        MessageWrapper.Untyped.struct_field x 1
      let has_originleft x =
        RA_.has_field x 2
      let originleft_get x =
        RA_.get_struct x 2
      let originleft_get_pipelined x =
        MessageWrapper.Untyped.struct_field x 2
      let has_originright x =
        RA_.has_field x 3
      let originright_get x =
        RA_.get_struct x 3
      let originright_get_pipelined x =
        MessageWrapper.Untyped.struct_field x 3
      let deleted_get x =
        RA_.get_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module VersionTuple = struct
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t reader_t
      let has_key x =
        RA_.has_field x 0
      let key_get x =
        RA_.get_text ~default:"" x 0
      let value_get x =
        RA_.get_int16 ~default:(0) x 0
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc = struct
        module Params = struct
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t reader_t
          let has_itemlist x =
            RA_.has_field x 0
          let itemlist_get x = 
            RA_.get_struct_list x 0
          let itemlist_get_list x =
            Capnp.Array.to_list (itemlist_get x)
          let itemlist_get_array x =
            Capnp.Array.to_array (itemlist_get x)
          let has_doccontent x =
            RA_.has_field x 1
          let doccontent_get x = 
            RA_.get_struct_list x 1
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
          let of_builder x = Some (RA_.StructStorage.readonly x)
        end
        module Results = struct
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t reader_t
          let has_itemlist x =
            RA_.has_field x 0
          let itemlist_get x = 
            RA_.get_struct_list x 0
          let itemlist_get_list x =
            Capnp.Array.to_list (itemlist_get x)
          let itemlist_get_array x =
            Capnp.Array.to_array (itemlist_get x)
          let has_doccontent x =
            RA_.has_field x 1
          let doccontent_get x = 
            RA_.get_struct_list x 1
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
          let of_builder x = Some (RA_.StructStorage.readonly x)
        end
      end
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module AgentU = struct
      type struct_t = [`AgentU_a977e52101cb24de]
      type t = struct_t builder_t
      module Message = struct
        type struct_t = [`Message_8eef0c28ea11163d]
        type t = struct_t builder_t
        let has_someagent x =
          BA_.has_field x 0
        let someagent_get x =
          BA_.get_text ~default:"" x 0
        let someagent_set x v =
          BA_.set_text ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=0} x 0 v
        let noneagent_get x = ()
        let noneagent_set x =
          BA_.set_void ~discr:{BA_.Discr.value=1; BA_.Discr.byte_ofs=0} x
        type unnamed_union_t =
          | Someagent of string
          | Noneagent
          | Undefined of int
        let get x =
          match BA_.get_uint16 ~default:0 x 0 with
          | 0 -> Someagent (someagent_get x)
          | 1 -> Noneagent
          | v -> Undefined v
        let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
        let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
        let to_reader x = Some (RA_.StructStorage.readonly x)
        let init_root ?message_size () =
          BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
        let init_pointer ptr =
          BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
      end
      let message_get x = BA_.cast_struct x
      let message_init x =
        let data = x.BA_.NM.StructStorage.data in
        let pointers = x.BA_.NM.StructStorage.pointers in
        let () = ignore data in
        let () = ignore pointers in
        let () = BA_.set_int16 ~default:0 x 0 0 in
        let () =
          let ptr = {
            pointers with
            MessageWrapper.Slice.start = pointers.MessageWrapper.Slice.start + 0;
            MessageWrapper.Slice.len = 8;
          } in
          let () = BA_.BOps.deep_zero_pointer ptr in
          MessageWrapper.Slice.set_int64 ptr 0 0L
        in
        BA_.cast_struct x
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
    module SeqU = struct
      type struct_t = [`SeqU_e8839c796c0dbfd2]
      type t = struct_t builder_t
      module Message = struct
        type struct_t = [`Message_8f90a95be910c25d]
        type t = struct_t builder_t
        let someseq_get x =
          BA_.get_int16 ~default:(0) x 0
        let someseq_set_exn x v =
          BA_.set_int16 ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=2} ~default:(0) x 0 v
        let noneseq_get x = ()
        let noneseq_set x =
          BA_.set_void ~discr:{BA_.Discr.value=1; BA_.Discr.byte_ofs=2} x
        type unnamed_union_t =
          | Someseq of int
          | Noneseq
          | Undefined of int
        let get x =
          match BA_.get_uint16 ~default:0 x 2 with
          | 0 -> Someseq (someseq_get x)
          | 1 -> Noneseq
          | v -> Undefined v
        let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:0 x
        let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
        let to_reader x = Some (RA_.StructStorage.readonly x)
        let init_root ?message_size () =
          BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:0 ()
        let init_pointer ptr =
          BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:0
      end
      let message_get x = BA_.cast_struct x
      let message_init x =
        let data = x.BA_.NM.StructStorage.data in
        let pointers = x.BA_.NM.StructStorage.pointers in
        let () = ignore data in
        let () = ignore pointers in
        let () = BA_.set_int16 ~default:0 x 2 0 in
        let () = BA_.set_int16 ~default:0 x 0 0 in
        BA_.cast_struct x
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:0 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:0 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:0
    end
    module Identity = struct
      type struct_t = [`Identity_9f86b55c0cb15216]
      type t = struct_t builder_t
      let has_agent x =
        BA_.has_field x 0
      let agent_get x =
        BA_.get_struct ~data_words:1 ~pointer_words:1 x 0
      let agent_set_reader x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 0 v
      let agent_set_builder x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 0 (Some v)
      let agent_init x =
        BA_.init_struct ~data_words:1 ~pointer_words:1 x 0
      let has_seq x =
        BA_.has_field x 1
      let seq_get x =
        BA_.get_struct ~data_words:1 ~pointer_words:0 x 1
      let seq_set_reader x v =
        BA_.set_struct ~data_words:1 ~pointer_words:0 x 1 v
      let seq_set_builder x v =
        BA_.set_struct ~data_words:1 ~pointer_words:0 x 1 (Some v)
      let seq_init x =
        BA_.init_struct ~data_words:1 ~pointer_words:0 x 1
      let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:2 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:2 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:2
    end
    module IdentityU = struct
      type struct_t = [`IdentityU_d092f1b45afbde2a]
      type t = struct_t builder_t
      module Message = struct
        type struct_t = [`Message_c569022e0ac5e919]
        type t = struct_t builder_t
        let has_someidentity x =
          BA_.has_field x 0
        let someidentity_get x =
          BA_.get_struct ~data_words:0 ~pointer_words:2 x 0
        let someidentity_set_reader x v =
          BA_.set_struct ~data_words:0 ~pointer_words:2 ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=0} x 0 v
        let someidentity_set_builder x v =
          BA_.set_struct ~data_words:0 ~pointer_words:2 ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=0} x 0 (Some v)
        let someidentity_init x =
          BA_.init_struct ~data_words:0 ~pointer_words:2 ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=0} x 0
        let noneidentity_get x = ()
        let noneidentity_set x =
          BA_.set_void ~discr:{BA_.Discr.value=1; BA_.Discr.byte_ofs=0} x
        type unnamed_union_t =
          | Someidentity of Identity.t
          | Noneidentity
          | Undefined of int
        let get x =
          match BA_.get_uint16 ~default:0 x 0 with
          | 0 -> Someidentity (someidentity_get x)
          | 1 -> Noneidentity
          | v -> Undefined v
        let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
        let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
        let to_reader x = Some (RA_.StructStorage.readonly x)
        let init_root ?message_size () =
          BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
        let init_pointer ptr =
          BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
      end
      let message_get x = BA_.cast_struct x
      let message_init x =
        let data = x.BA_.NM.StructStorage.data in
        let pointers = x.BA_.NM.StructStorage.pointers in
        let () = ignore data in
        let () = ignore pointers in
        let () = BA_.set_int16 ~default:0 x 0 0 in
        let () =
          let ptr = {
            pointers with
            MessageWrapper.Slice.start = pointers.MessageWrapper.Slice.start + 0;
            MessageWrapper.Slice.len = 8;
          } in
          let () = BA_.BOps.deep_zero_pointer ptr in
          MessageWrapper.Slice.set_int64 ptr 0 0L
        in
        BA_.cast_struct x
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
    module Ident = struct
      type struct_t = [`Ident_c1e4df594ee0d9e2]
      type t = struct_t builder_t
      let has_agent x =
        BA_.has_field x 0
      let agent_get x =
        BA_.get_text ~default:"" x 0
      let agent_set x v =
        BA_.set_text x 0 v
      let seq_get x =
        BA_.get_int16 ~default:(0) x 0
      let seq_set_exn x v =
        BA_.set_int16 ~default:(0) x 0 v
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
    module Item = struct
      type struct_t = [`Item_cd0899f5127dcb10]
      type t = struct_t builder_t
      let has_content x =
        BA_.has_field x 0
      let content_get x =
        BA_.get_text ~default:"" x 0
      let content_set x v =
        BA_.set_text x 0 v
      let has_id x =
        BA_.has_field x 1
      let id_get x =
        BA_.get_struct ~data_words:1 ~pointer_words:1 x 1
      let id_set_reader x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 1 v
      let id_set_builder x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 1 (Some v)
      let id_init x =
        BA_.init_struct ~data_words:1 ~pointer_words:1 x 1
      let has_originleft x =
        BA_.has_field x 2
      let originleft_get x =
        BA_.get_struct ~data_words:1 ~pointer_words:1 x 2
      let originleft_set_reader x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 2 v
      let originleft_set_builder x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 2 (Some v)
      let originleft_init x =
        BA_.init_struct ~data_words:1 ~pointer_words:1 x 2
      let has_originright x =
        BA_.has_field x 3
      let originright_get x =
        BA_.get_struct ~data_words:1 ~pointer_words:1 x 3
      let originright_set_reader x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 3 v
      let originright_set_builder x v =
        BA_.set_struct ~data_words:1 ~pointer_words:1 x 3 (Some v)
      let originright_init x =
        BA_.init_struct ~data_words:1 ~pointer_words:1 x 3
      let deleted_get x =
        BA_.get_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0
      let deleted_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0 v
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:4 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:4 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:4
    end
    module VersionTuple = struct
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t builder_t
      let has_key x =
        BA_.has_field x 0
      let key_get x =
        BA_.get_text ~default:"" x 0
      let key_set x v =
        BA_.set_text x 0 v
      let value_get x =
        BA_.get_int16 ~default:(0) x 0
      let value_set_exn x v =
        BA_.set_int16 ~default:(0) x 0 v
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc = struct
        module Params = struct
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t builder_t
          let has_itemlist x =
            BA_.has_field x 0
          let itemlist_get x = 
            BA_.get_struct_list ~data_words:1 ~pointer_words:4 x 0
          let itemlist_get_list x =
            Capnp.Array.to_list (itemlist_get x)
          let itemlist_get_array x =
            Capnp.Array.to_array (itemlist_get x)
          let itemlist_set x v =
            BA_.set_struct_list ~data_words:1 ~pointer_words:4 x 0 v
          let itemlist_init x n =
            BA_.init_struct_list ~data_words:1 ~pointer_words:4 x 0 n
          let itemlist_set_list x v =
            let builder = itemlist_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let itemlist_set_array x v =
            let builder = itemlist_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let has_doccontent x =
            BA_.has_field x 1
          let doccontent_get x = 
            BA_.get_struct_list ~data_words:1 ~pointer_words:1 x 1
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let doccontent_set x v =
            BA_.set_struct_list ~data_words:1 ~pointer_words:1 x 1 v
          let doccontent_init x n =
            BA_.init_struct_list ~data_words:1 ~pointer_words:1 x 1 n
          let doccontent_set_list x v =
            let builder = doccontent_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let doccontent_set_array x v =
            let builder = doccontent_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:2 x
          let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
          let to_reader x = Some (RA_.StructStorage.readonly x)
          let init_root ?message_size () =
            BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:2 ()
          let init_pointer ptr =
            BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:2
        end
        module Results = struct
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t builder_t
          let has_itemlist x =
            BA_.has_field x 0
          let itemlist_get x = 
            BA_.get_struct_list ~data_words:1 ~pointer_words:4 x 0
          let itemlist_get_list x =
            Capnp.Array.to_list (itemlist_get x)
          let itemlist_get_array x =
            Capnp.Array.to_array (itemlist_get x)
          let itemlist_set x v =
            BA_.set_struct_list ~data_words:1 ~pointer_words:4 x 0 v
          let itemlist_init x n =
            BA_.init_struct_list ~data_words:1 ~pointer_words:4 x 0 n
          let itemlist_set_list x v =
            let builder = itemlist_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let itemlist_set_array x v =
            let builder = itemlist_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let has_doccontent x =
            BA_.has_field x 1
          let doccontent_get x = 
            BA_.get_struct_list ~data_words:1 ~pointer_words:1 x 1
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let doccontent_set x v =
            BA_.set_struct_list ~data_words:1 ~pointer_words:1 x 1 v
          let doccontent_init x n =
            BA_.init_struct_list ~data_words:1 ~pointer_words:1 x 1 n
          let doccontent_set_list x v =
            let builder = doccontent_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let doccontent_set_array x v =
            let builder = doccontent_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:2 x
          let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
          let to_reader x = Some (RA_.StructStorage.readonly x)
          let init_root ?message_size () =
            BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:2 ()
          let init_pointer ptr =
            BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:2
        end
      end
    end
  end

  module Client = struct
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      let interface_id = Stdint.Uint64.of_string "0xa32eddf67702f1ec"
      module Mergedoc = struct
        module Params = Builder.MergeDoc.Mergedoc.Params
        module Results = Reader.MergeDoc.Mergedoc.Results
        let method_id : (t, Params.t, Results.t) Capnp.RPC.MethodID.t =
          Capnp.RPC.MethodID.v ~interface_id ~method_id:0
      end
      let method_name = function
        | 0 -> Some "mergedoc"
        | _ -> None
      let () = Capnp.RPC.Registry.register ~interface_id ~name:"MergeDoc" method_name
    end
  end

  module Service = struct
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      let interface_id = Stdint.Uint64.of_string "0xa32eddf67702f1ec"
      module Mergedoc = struct
        module Params = Reader.MergeDoc.Mergedoc.Params
        module Results = Builder.MergeDoc.Mergedoc.Results
      end
      class virtual service = object (self)
        method release = ()
        method dispatch ~interface_id:i ~method_id =
          if i <> interface_id then MessageWrapper.Untyped.unknown_interface ~interface_id:i
          else match method_id with
          | 0 -> MessageWrapper.Untyped.abstract_method self#mergedoc_impl
          | x -> MessageWrapper.Untyped.unknown_method ~interface_id ~method_id
        method pp f = Format.pp_print_string f "MergeDoc"
        method virtual mergedoc_impl : (Mergedoc.Params.t, Mergedoc.Results.t) MessageWrapper.Service.method_t
      end
      let local (service:#service) =
        MessageWrapper.Untyped.local service
    end
  end
  module MessageWrapper = MessageWrapper
end

module Make(M:Capnp.MessageSig.S) = MakeRPC(Capnp.RPC.None(M))
