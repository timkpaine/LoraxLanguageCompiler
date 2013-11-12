(* 
 * Authors:
 * Chris D'Angelo
 * Special thanks to Dara Hazeghi's strlang which provided background knowledge.
 *)

type op = 
      Add 
    | Sub 
    | Mult 
    | Div 
    | Mod 
    | Equal 
    | Neq 
    | Less 
    | Leq 
    | Greater 
    | Geq
    | Child
    | And
    | Or

type uop =
      Neg
    | Not
    | At

type expr =
    Int_Literal of int
  | Float_Literal of float
  | String_Literal of string
  | Char_Literal of char
  | Bool_Literal of bool
  | Id of string
  | Binop of expr * op * expr
  | Unop of expr * uop
  | Tree of expr * expr list
  | Assign of string * expr
  | Call of string * expr list
  | Noexpr

type atom_type =
    Lrx_Int
  | Lrx_Float
  | Lrx_Bool
  | Lrx_Char

type tree_decl = {
    lrxtype : atom_type;
    degree : expr;
}

type var_type =
    Lrx_Tree of tree_decl
  | Lrx_Atom of atom_type

type var = string * var_type

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt
  | Continue
  | Break

type func_decl = {
    fname : string;
    formals : string list; (* TODO: needs to be a var list *)
    locals : var list;
    body : stmt list;
  }

type program = var list * func_decl list

let string_of_binop = function
        Add -> "+" 
      | Sub -> "-" 
      | Mult -> "*" 
      | Div -> "/" 
      | Mod -> "mod"
      | Child -> "%"
      | Equal -> "==" 
      | Neq -> "!="
      | Less -> "<" 
      | Leq -> "<=" 
      | Greater -> ">" 
      | Geq -> ">="
      | And -> "&&"
      | Or -> "||"

let rec string_of_expr = function
    Int_Literal(l) -> string_of_int l
  | Float_Literal(l) -> string_of_float l
  | String_Literal(l) -> "\"" ^ l ^ "\""
  | Char_Literal(l) -> "\'" ^ (String.make 1) l ^"\'"
  | Bool_Literal(l) -> string_of_bool l
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^
      string_of_binop o ^ " " ^
      string_of_expr e2
  | Unop(e, o) -> 
      (match o with 
          Neg -> "-" ^ string_of_expr e
        | Not -> "!" ^ string_of_expr e
        | At -> string_of_expr e ^ "@")
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Tree(r, cl) -> string_of_expr r ^ "[" ^ String.concat ", " (List.map string_of_expr cl) ^ "]"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s
  | Break -> "break;"
  | Continue -> "continue;"

(* let string_of_vdecl id = "int " ^ id ^ ";\n" *)

let string_of_atom_type = function
    Lrx_Int -> "int"
  | Lrx_Float -> "float"
  | Lrx_Bool -> "bool"
  | Lrx_Char -> "char"

let string_of_vdecl v =
    (match (snd v) with
        Lrx_Atom(t) -> string_of_atom_type t ^ " " ^ fst v ^ ";\n"
      | Lrx_Tree(t) -> "<" ^ string_of_atom_type t.lrxtype ^ ">" ^ fst v ^ "(" ^ string_of_expr t.degree ^ ");\n"
    )

let string_of_fdecl fdecl =
  fdecl.fname ^ "(" ^ String.concat ", " fdecl.formals ^ ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)
