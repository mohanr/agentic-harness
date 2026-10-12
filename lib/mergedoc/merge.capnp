@0xc6f77289e1b5b950;

struct AgentU{
  message :union {
    someagent @0 :Text;
    noneagent @1 :Void;
  }
}

struct SeqU{
  message :union {
    someseq @0 :Int16;
    noneseq @1 :Void;
  }
}

struct Identity  {
  agent @0 : AgentU;
  seq @1 :  SeqU;
}


struct IdentityU{
  message :union {
    someidentity @0 :Identity;
    noneidentity @1 :Void;
  }
}

struct Ident  {
  agent @0 : Text;
  seq @1 :  Int16;
}

struct Item {
  content @0 : Text;
  id @1 : Ident  ;
  originleft @2 : IdentityU;
  originright @3 :IdentityU;
  deleted @4 :  Bool;
}

struct VersionTuple{
    key @0 :Text;
    value @1 :Int16;
}

interface MergeDoc {
  mergedoc @0 (itemlist :List(Item),
               doccontent :List(VersionTuple)) ->
(itemlist :List(Item),
               doccontent :List(VersionTuple));
}
