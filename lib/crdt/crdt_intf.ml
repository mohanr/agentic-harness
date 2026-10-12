open Types

module type Intf = sig
module CRDTOp : CRDTOperator
end
