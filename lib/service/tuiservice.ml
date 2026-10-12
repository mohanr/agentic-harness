open Service
open Eio.Std
open Tuioperator
open Crdt
open Logger.Logger


let secret_key = `Ephemeral

module TuiService = struct

module Make( TUIOp: TUIHandler) = struct

module RemoteMergeOp = MergeService(CRDTOp)


let start_server  (net : Eio_unix.Net.t ) env listen_address file_path _id =
  Eio.Switch.run (fun sw ->

  let config = Capnp_rpc_unix.Vat_config.create ~serve_tls:false ~secret_key ~net listen_address in
  let service_id = Capnp_rpc_unix.Vat_config.derived_id config "main" in

  let restore = Capnp_rpc_net.Restorer.single service_id (RemoteMergeOp.merge_local) in

  let vat = Capnp_rpc_unix.serve ~sw ~restore config in

  (match Capnp_rpc_unix.Cap_file.save_service vat service_id file_path with
  | Error `Msg m -> failwith m
  | Ok () ->
    let _ = log_m "Server running. Connect using %S." file_path in ();
  );
  TUIOp.periodic_timer env;
  try

    Fiber.await_cancel()
  with Eio.Cancel.Cancelled _ ->
     traceln  "Cancelled"
  )

end


(* with *)
(* | Unix_error(Unix.EADDRINUSE, "bind", _) -> *)
(*   Printf.printf "EADDRINUSE" *)

end
