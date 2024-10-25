open Yojson

type ppos = Lexing.position * Lexing.position

type program = 
  global_stmt list

and global_stmt =
  | GFunDef of string * string * arg list * stmt * ppos
  | GVarDef of string * string * int * expr option * ppos

and arg =
  | Arg of string * string * ppos

and stmt =  
  | Sscope of stmt list  * ppos
  | Sreturn of expr option * ppos
  (* | SreturnVoid of ppos *)

  | Sfor of stmt * expr * stmt * stmt * ppos (* s1 ; cond ; s2 {} *)
  | Swhile of expr * stmt * ppos

  (* | SvarDef of string * string * ppos *)
  | SvarDef of string * string * int * expr option * ppos
  | SvarSet of left_value * assingop * expr * ppos
  | Sexpr of expr * ppos

  | Sif of expr * stmt * ppos
  | SifElse of expr * stmt * stmt * ppos

and litteral = 
  | Void of ppos
  | Int of int * ppos
  | Bool of bool * ppos
  | Char of char * ppos
  | String of string * ppos

and left_value = 
  | ArrayGet of left_value * expr * ppos
  | VarGet of string * ppos

and expr =
  | Const of litteral * ppos
  | ValueGet of left_value * ppos
  | List of expr list * ppos
  | FunCall of string * expr list * ppos

  | LeftValOp of leftvalop * left_value * ppos
  | Uniop of uniop * expr * ppos
  | Binop of binop * expr * expr * ppos
  | Ternop of expr * expr * expr * ppos


and leftvalop =
  | POSTINCR
  | POSTDECR
  | PREINCR
  | PREDECR
  | GetAdress

and binop = 
  Add | Sub | Mul | Div | Mod | 
  Leq | Le | Geq | Ge | Neq | IsEq | 
  And | Or | 
  Xor | Lshift | Rshift | BAnd | BOr

and uniop =
  (* | StructGet
  | StructPtrGet *)
  | Dereference
  | Neg 
  | Not
  | Inv

and assingop =
  | Eq
  | AddEq
  | SubEq
  | MulEq
  | DivEq
  | ModEq

let str_binop = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Leq -> "<="
  | Le -> "<"
  | Geq -> ">="
  | Ge -> ">"
  | Neq -> "!="
  | IsEq -> "=="
  | And -> "&&"
  | Or -> "||"
  | Xor -> "^"
  | Lshift -> "<<"
  | Rshift -> ">>"
  | BAnd -> "&"
  | BOr -> "|"

let str_uniop = function
  | Neg -> "-"
  | Not -> "!"
  | Inv -> "~"
  | Dereference -> "*x"
  (* | StructGet -> "."
  | StructPtrGet -> "->" *)

let str_leftvalop = function
  | POSTINCR -> "x++"
  | POSTDECR -> "x--"
  | PREINCR -> "++x"
  | PREDECR -> "--x"
  | GetAdress -> "&x"

let str_assingop = function
  | Eq -> "="
  | AddEq -> "+="
  | SubEq -> "-="
  | MulEq -> "*="
  | DivEq -> "/="
  | ModEq -> "%="

let pos ((s,e):ppos) =
  (* [ "start_line",`Int s.pos_lnum ;
  "start_char",`Int (s.pos_cnum-s.pos_bol) ;
  "end_line",`Int e.pos_lnum ;
  "end_char",`Int (e.pos_cnum-e.pos_bol) ] *)
  []

let rec toJSON (p:program) : Yojson.t =
  `List (List.map toJSONgstmt p)

and toJSONgstmt = function
  | GFunDef(t,n, a, b, p) -> `Assoc ([
    "action", `String "fundef" ;
    "type", `String t ;
    "name", `String n ;
    "args", `List (List.map toJSONarg a) ;
    "body", toJSONstmt b ] @ pos p)
  | GVarDef(t, n, i, e, p) -> `Assoc ([
    "action", `String "gvardef" ;
    "type", `String t ;
    "name", `String n ;
    "size", `Int i ;
    "value", match e with
      | None -> `Assoc ([])
      | Some x -> toJSONexpr x 
    ] @ pos p)

and toJSONarg = function
  | Arg(t, n, p) -> `Assoc ([
    "action", `String "arg" ;
    "type", `String t ;
    "name", `String n ] @ pos p)

and toJSONstmt = function
  | Sscope(l, p) -> `Assoc ([
    "action", `String "scope" ;
    "body", `List (List.map toJSONstmt l) ] @ pos p)
  | Sreturn(e, p) -> `Assoc ([
    "action", `String "return" ;
    "value", match e with 
      | None -> toJSONlitteral (Void p)
      | Some x -> toJSONexpr x
    ] @ pos p)
  (* | SreturnVoid(p) -> `Assoc ([
    "action", `String "return" ;
    "value",  ] @ pos p) *)
  | Sfor(i, c, u, b, p) -> `Assoc ([
    "action", `String "for" ;
    "init", toJSONstmt i ;
    "condition", toJSONexpr c ;
    "update", toJSONstmt u ;
    "body", toJSONstmt b ] @ pos p)
  | Swhile(e, s, p) -> `Assoc ([
    "action", `String "while" ;
    "condition", toJSONexpr e ;
    "body", toJSONstmt s ] @ pos p)
  (* | SvarDef(t, n, p) -> `Assoc ([
    "action", `String "vardef" ;
    "type", `String t ;
    "name", `String n ;
    "value", `Assoc ([]) ] @ pos p) *)
  | SvarDef(t, n, i,e, p) -> `Assoc ([
    "action", `String "vardef" ;
    "type", `String t ;
    "name", `String n ;
    "size", `Int i ;
    "value", match e with
      | None -> `Assoc ([])
      | Some x -> toJSONexpr x
    ] @ pos p)
  | SvarSet(l, op , e, p) -> `Assoc ([
    "action", `String "varset" ;
    "left_value", toJSONleft_value l ;
    "op", `String (str_assingop op) ;
    "value", toJSONexpr e ] @ pos p)
  | Sexpr(e, p) -> `Assoc ([
    "action", `String "expr" ;
    "value", toJSONexpr e ] @ pos p)
  | Sif(e, s, p) -> `Assoc ([
    "action", `String "if" ;
    "condition", toJSONexpr e ;
    "body", toJSONstmt s ] @ pos p)
  | SifElse(e, s1, s2, p) -> `Assoc ([
    "action", `String "ifelse" ;
    "condition", toJSONexpr e ;
    "body_if", toJSONstmt s1 ;
    "body_else", toJSONstmt s2 ] @ pos p)
    
and toJSONlitteral = function
  | Void p -> `Assoc ([
    "action", `String "void" ] @ pos p)
  | Int(i, p) -> `Assoc ([
    "action", `String "int" ;
    "value", `Int i ] @ pos p)
  | Bool(b, p) -> `Assoc ([
    "action", `String "bool" ;
    "value", `Bool b ] @ pos p)
  | Char(c, p) -> `Assoc ([
    "action", `String "char" ;
    "value", `String (String.make 1 c) ] @ pos p)
  | String(s, p) -> `Assoc ([
    "action", `String "string" ;
    "value", `String s ] @ pos p)
  
and toJSONleft_value = function
  | VarGet(n, p) -> `Assoc ([
    "action", `String "varget" ;
    "name", `String n ] @ pos p)
  | ArrayGet(l, e, p) -> `Assoc ([
    "action", `String "arrayget" ;
    "left_value", toJSONleft_value l ;
    "index", toJSONexpr e ] @ pos p)

and toJSONexpr = function
  | Const(c, p) -> `Assoc ([
    "action", `String "const" ;
    "value", toJSONlitteral c ] @ pos p)
  | ValueGet(lv, p) -> `Assoc ([
    "action", `String "valueget" ;
    "value", toJSONleft_value lv ] @ pos p)
  | List(l, p) -> `Assoc ([
    "action", `String "list" ;
    "values", `List (List.map toJSONexpr l) ] @ pos p)
  | FunCall(f, l, p) -> `Assoc ([
    "action", `String "funcall" ;
    "name", `String f ;
    "args", `List (List.map toJSONexpr l) ] @ pos p)
  | LeftValOp(o, lv, p) -> `Assoc ([
    "action", `String "leftvalop" ;
    "left_value", toJSONleft_value lv ;
    "op", `String (str_leftvalop o) ] @ pos p)
  | Uniop(o, e, p) -> `Assoc ([
    "action", `String "uniop" ;
    "uniop", `String (str_uniop o) ;
    "value", toJSONexpr e ] @ pos p)
  | Binop(o, e1, e2, p) -> `Assoc ([
    "action", `String "binop" ;
    "binop", `String (str_binop o) ;
    "v1", toJSONexpr e1 ;
    "v2", toJSONexpr e2 ] @ pos p)
  | Ternop(e1, e2, e3, p) -> `Assoc ([
    "action", `String "ternop" ;
    "condition", toJSONexpr e1 ;
    "v1", toJSONexpr e2 ;
    "v2", toJSONexpr e3 ] @ pos p)



  
