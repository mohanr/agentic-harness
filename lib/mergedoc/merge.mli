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

module MakeRPC(MessageWrapper : Capnp.RPC.S) : sig
  include S with module MessageWrapper = MessageWrapper

  module Client : sig
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      val interface_id : Stdint.Uint64.t
      module Mergedoc : sig
        module Params = Builder.MergeDoc.Mergedoc.Params
        module Results = Reader.MergeDoc.Mergedoc.Results
        val method_id : (t, Params.t, Results.t) Capnp.RPC.MethodID.t
      end
    end
  end

  module Service : sig
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      val interface_id : Stdint.Uint64.t
      module Mergedoc : sig
        module Params = Reader.MergeDoc.Mergedoc.Params
        module Results = Builder.MergeDoc.Mergedoc.Results
      end
      class virtual service : object
        inherit MessageWrapper.Untyped.generic_service
        method virtual mergedoc_impl : (Mergedoc.Params.t, Mergedoc.Results.t) MessageWrapper.Service.method_t
      end
      val local : #service -> t MessageWrapper.Capability.t
    end
  end
end

module Make(M : Capnp.MessageSig.S) : module type of MakeRPC(Capnp.RPC.None(M))
