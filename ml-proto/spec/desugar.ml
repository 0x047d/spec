open Source
open Types
open Values
open Memory
open Kernel


(* Labels *)

let rec label e = shift 0 e
and shift n e = shift' n e.it @@ e.at
and shift' n = function
  | Nop -> Nop
  | Unreachable -> Unreachable
  | Block es -> Block (List.map (shift (n + 1)) es)
  | Loop e -> Loop (shift (n + 1) e)
  | Break (x, eo) ->
    let x' = if x.it < n then x else (x.it + 1) @@ x.at in
    Break (x', Lib.Option.map (shift n) eo)
  | Br_if (x, eo, e) ->
    let x' = if x.it < n then x else (x.it + 1) @@ x.at in
    Br_if (x', Lib.Option.map (shift n) eo, shift n e)
  | If (e1, e2, e3) -> If (shift n e1, shift n e2, shift n e3)
  | Switch (e, xs, x, es) -> Switch (shift n e, xs, x, List.map (shift n) es)
  | Call (x, es) -> Call (x, List.map (shift n) es)
  | CallImport (x, es) -> CallImport (x, List.map (shift n) es)
  | CallIndirect (x, e, es) ->
    CallIndirect (x, shift n e, List.map (shift n) es)
  | GetLocal x -> GetLocal x
  | SetLocal (x, e) -> SetLocal (x, shift n e)
  | Load (memop, e) -> Load (memop, shift n e)
  | Store (memop, e1, e2) -> Store (memop, shift n e1, shift n e2)
  | LoadExtend (extop, e) -> LoadExtend (extop, shift n e)
  | StoreWrap (wrapop, e1, e2) -> StoreWrap (wrapop, shift n e1, shift n e2)
  | Const c -> Const c
  | Unary (unop, e) -> Unary (unop, shift n e)
  | Binary (binop, e1, e2) -> Binary (binop, shift n e1, shift n e2)
  | Select (selop, e1, e2, e3) ->
    Select (selop, shift n e1, shift n e2, shift n e3)
  | Compare (relop, e1, e2) -> Compare (relop, shift n e1, shift n e2)
  | Convert (cvtop, e) -> Convert (cvtop, shift n e)
  | Host (hostop, es) -> Host (hostop, List.map (shift n) es)


(* Expressions *)

let rec expr e = expr' e.at e.it @@ e.at
and expr' at = function
  | Ast.I32_const n -> Const (Int32 n.it @@ n.at)
  | Ast.I64_const n -> Const (Int64 n.it @@ n.at)
  | Ast.F32_const n -> Const (Float32 n.it @@ n.at)
  | Ast.F64_const n -> Const (Float64 n.it @@ n.at)

  | Ast.Nop -> Nop
  | Ast.Unreachable -> Unreachable
  | Ast.Block es -> Block (List.map expr es)
  | Ast.Loop es -> Block [Loop (block es) @@ at]
  | Ast.Br (x, eo) -> Break (x, Lib.Option.map expr eo)
  | Ast.Br_if (x, eo, e) -> Br_if (x, Lib.Option.map expr eo, expr e)
  | Ast.Return (x, eo) -> Break (x, Lib.Option.map expr eo)
  | Ast.If (e, es) -> If (expr e, block es, Nop @@ Source.after e2.at)
  | Ast.If_else (e, es1, es2) -> If (expr e, block es1, block es2)
  | Ast.Call (x, es) -> Call (x, List.map expr es)
  | Ast.Call_import (x, es) -> CallImport (x, List.map expr es)
  | Ast.Call_indirect (x, e, es) -> CallIndirect (x, expr e, List.map expr es)

  | Ast.Tableswitch (e, ts, t, es) ->
    let target t (xs, es') =
      match t.it with
      | Ast.Case x -> x :: xs, es'
      | Ast.Case_br x ->
        (List.length es' @@ t.at) :: xs, (Break (x, None) @@ t.at) :: es'
    in
    let xs, es' = List.fold_right target (t :: ts) ([], []) in
    let es'' = List.map expr es in
    let n = List.length es' in
    let sh x = (if x.it >= n then x.it + n else x.it) @@ x.at in
    Block [Switch
      (expr e, List.map sh (List.tl xs), sh (List.hd xs), List.rev es' @ es'')
      @@ at]

  | Ast.Get_local x -> GetLocal x
  | Ast.Set_local (x, e) -> SetLocal (x, expr e)

  | Ast.I32_load (offset, align, e) ->
    Load ({ty = Int32Type; offset; align}, expr e)
  | Ast.I64_load (offset, align, e) ->
    Load ({ty = Int64Type; offset; align}, expr e)
  | Ast.F32_load (offset, align, e) ->
    Load ({ty = Float32Type; offset; align}, expr e)
  | Ast.F64_load (offset, align, e) ->
    Load ({ty = Float64Type; offset; align}, expr e)
  | Ast.I32_store (offset, align, e1, e2) ->
    Store ({ty = Int32Type; offset; align}, expr e1, expr e2)
  | Ast.I64_store (offset, align, e1, e2) ->
    Store ({ty = Int64Type; offset; align}, expr e1, expr e2)
  | Ast.F32_store (offset, align, e1, e2) ->
    Store ({ty = Float32Type; offset; align}, expr e1, expr e2)
  | Ast.F64_store (offset, align, e1, e2) ->
    Store ({ty = Float64Type; offset; align}, expr e1, expr e2)
  | Ast.I32_load8_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem8; ext = SX}, expr e)
  | Ast.I32_load8_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem8; ext = ZX}, expr e)
  | Ast.I32_load16_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem16; ext = SX}, expr e)
  | Ast.I32_load16_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem16; ext = ZX}, expr e)
  | Ast.I32_load32_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem32; ext = SX}, expr e)
  | Ast.I32_load32_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int32Type; offset; align}; sz = Mem32; ext = ZX}, expr e)
  | Ast.I64_load8_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem8; ext = SX}, expr e)
  | Ast.I64_load8_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem8; ext = ZX}, expr e)
  | Ast.I64_load16_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem16; ext = SX}, expr e)
  | Ast.I64_load16_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem16; ext = ZX}, expr e)
  | Ast.I64_load32_s (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem32; ext = SX}, expr e)
  | Ast.I64_load32_u (offset, align, e) ->
    LoadExtend
      ({memop = {ty = Int64Type; offset; align}; sz = Mem32; ext = ZX}, expr e)
  | Ast.I32_store8 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int32Type; offset; align}; sz = Mem8}, expr e1, expr e2)
  | Ast.I32_store16 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int32Type; offset; align}; sz = Mem16}, expr e1, expr e2)
  | Ast.I32_store32 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int32Type; offset; align}; sz = Mem32}, expr e1, expr e2)
  | Ast.I64_store8 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int64Type; offset; align}; sz = Mem8}, expr e1, expr e2)
  | Ast.I64_store16 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int64Type; offset; align}; sz = Mem16}, expr e1, expr e2)
  | Ast.I64_store32 (offset, align, e1, e2) ->
    StoreWrap
      ({memop = {ty = Int64Type; offset; align}; sz = Mem32}, expr e1, expr e2)

  | Ast.I32_clz e -> Unary (Int32 I32Op.Clz, expr e)
  | Ast.I32_ctz e -> Unary (Int32 I32Op.Ctz, expr e)
  | Ast.I32_popcnt e -> Unary (Int32 I32Op.Popcnt, expr e)
  | Ast.I64_clz e -> Unary (Int64 I64Op.Clz, expr e)
  | Ast.I64_ctz e -> Unary (Int64 I64Op.Ctz, expr e)
  | Ast.I64_popcnt e -> Unary (Int64 I64Op.Popcnt, expr e)
  | Ast.F32_neg e -> Unary (Float32 F32Op.Neg, expr e)
  | Ast.F32_abs e -> Unary (Float32 F32Op.Abs, expr e)
  | Ast.F32_sqrt e -> Unary (Float32 F32Op.Sqrt, expr e)
  | Ast.F32_ceil e -> Unary (Float32 F32Op.Ceil, expr e)
  | Ast.F32_floor e -> Unary (Float32 F32Op.Floor, expr e)
  | Ast.F32_trunc e -> Unary (Float32 F32Op.Trunc, expr e)
  | Ast.F32_nearest e -> Unary (Float32 F32Op.Nearest, expr e)
  | Ast.F64_neg e -> Unary (Float64 F64Op.Neg, expr e)
  | Ast.F64_abs e -> Unary (Float64 F64Op.Abs, expr e)
  | Ast.F64_sqrt e -> Unary (Float64 F64Op.Sqrt, expr e)
  | Ast.F64_ceil e -> Unary (Float64 F64Op.Ceil, expr e)
  | Ast.F64_floor e -> Unary (Float64 F64Op.Floor, expr e)
  | Ast.F64_trunc e -> Unary (Float64 F64Op.Trunc, expr e)
  | Ast.F64_nearest e -> Unary (Float64 F64Op.Nearest, expr e)

  | Ast.I32_add (e1, e2) -> Binary (Int32 I32Op.Add, expr e1, expr e2)
  | Ast.I32_sub (e1, e2) -> Binary (Int32 I32Op.Sub, expr e1, expr e2)
  | Ast.I32_mul (e1, e2) -> Binary (Int32 I32Op.Mul, expr e1, expr e2)
  | Ast.I32_div_s (e1, e2) -> Binary (Int32 I32Op.DivS, expr e1, expr e2)
  | Ast.I32_div_u (e1, e2) -> Binary (Int32 I32Op.DivU, expr e1, expr e2)
  | Ast.I32_rem_s (e1, e2) -> Binary (Int32 I32Op.RemS, expr e1, expr e2)
  | Ast.I32_rem_u (e1, e2) -> Binary (Int32 I32Op.RemU, expr e1, expr e2)
  | Ast.I32_and (e1, e2) -> Binary (Int32 I32Op.And, expr e1, expr e2)
  | Ast.I32_or (e1, e2) -> Binary (Int32 I32Op.Or, expr e1, expr e2)
  | Ast.I32_xor (e1, e2) -> Binary (Int32 I32Op.Xor, expr e1, expr e2)
  | Ast.I32_shl (e1, e2) -> Binary (Int32 I32Op.Shl, expr e1, expr e2)
  | Ast.I32_shr_s (e1, e2) -> Binary (Int32 I32Op.ShrS, expr e1, expr e2)
  | Ast.I32_shr_u (e1, e2) -> Binary (Int32 I32Op.ShrU, expr e1, expr e2)
  | Ast.I64_add (e1, e2) -> Binary (Int64 I64Op.Add, expr e1, expr e2)
  | Ast.I64_sub (e1, e2) -> Binary (Int64 I64Op.Sub, expr e1, expr e2)
  | Ast.I64_mul (e1, e2) -> Binary (Int64 I64Op.Mul, expr e1, expr e2)
  | Ast.I64_div_s (e1, e2) -> Binary (Int64 I64Op.DivS, expr e1, expr e2)
  | Ast.I64_div_u (e1, e2) -> Binary (Int64 I64Op.DivU, expr e1, expr e2)
  | Ast.I64_rem_s (e1, e2) -> Binary (Int64 I64Op.RemS, expr e1, expr e2)
  | Ast.I64_rem_u (e1, e2) -> Binary (Int64 I64Op.RemU, expr e1, expr e2)
  | Ast.I64_and (e1, e2) -> Binary (Int64 I64Op.And, expr e1, expr e2)
  | Ast.I64_or (e1, e2) -> Binary (Int64 I64Op.Or, expr e1, expr e2)
  | Ast.I64_xor (e1, e2) -> Binary (Int64 I64Op.Xor, expr e1, expr e2)
  | Ast.I64_shl (e1, e2) -> Binary (Int64 I64Op.Shl, expr e1, expr e2)
  | Ast.I64_shr_s (e1, e2) -> Binary (Int64 I64Op.ShrS, expr e1, expr e2)
  | Ast.I64_shr_u (e1, e2) -> Binary (Int64 I64Op.ShrU, expr e1, expr e2)
  | Ast.F32_add (e1, e2) -> Binary (Float32 F32Op.Add, expr e1, expr e2)
  | Ast.F32_sub (e1, e2) -> Binary (Float32 F32Op.Sub, expr e1, expr e2)
  | Ast.F32_mul (e1, e2) -> Binary (Float32 F32Op.Mul, expr e1, expr e2)
  | Ast.F32_div (e1, e2) -> Binary (Float32 F32Op.Div, expr e1, expr e2)
  | Ast.F32_min (e1, e2) -> Binary (Float32 F32Op.Min, expr e1, expr e2)
  | Ast.F32_max (e1, e2) -> Binary (Float32 F32Op.Max, expr e1, expr e2)
  | Ast.F32_copysign (e1, e2) ->
    Binary (Float32 F32Op.CopySign, expr e1, expr e2)
  | Ast.F64_add (e1, e2) -> Binary (Float64 F64Op.Add, expr e1, expr e2)
  | Ast.F64_sub (e1, e2) -> Binary (Float64 F64Op.Sub, expr e1, expr e2)
  | Ast.F64_mul (e1, e2) -> Binary (Float64 F64Op.Mul, expr e1, expr e2)
  | Ast.F64_div (e1, e2) -> Binary (Float64 F64Op.Div, expr e1, expr e2)
  | Ast.F64_min (e1, e2) -> Binary (Float64 F64Op.Min, expr e1, expr e2)
  | Ast.F64_max (e1, e2) -> Binary (Float64 F64Op.Max, expr e1, expr e2)
  | Ast.F64_copysign (e1, e2) ->
    Binary (Float64 F64Op.CopySign, expr e1, expr e2)

  | Ast.I32_select (e1, e2, e3) ->
    Select (Int32 I32Op.Select, expr e1, expr e2, expr e3)
  | Ast.I64_select (e1, e2, e3) ->
    Select (Int64 I64Op.Select, expr e1, expr e2, expr e3)
  | Ast.F32_select (e1, e2, e3) ->
    Select (Float32 F32Op.Select, expr e1, expr e2, expr e3)
  | Ast.F64_select (e1, e2, e3) ->
    Select (Float64 F64Op.Select, expr e1, expr e2, expr e3)

  | Ast.I32_eq (e1, e2) -> Compare (Int32 I32Op.Eq, expr e1, expr e2)
  | Ast.I32_ne (e1, e2) -> Compare (Int32 I32Op.Ne, expr e1, expr e2)
  | Ast.I32_lt_s (e1, e2) -> Compare (Int32 I32Op.LtS, expr e1, expr e2)
  | Ast.I32_lt_u (e1, e2) -> Compare (Int32 I32Op.LtU, expr e1, expr e2)
  | Ast.I32_le_s (e1, e2) -> Compare (Int32 I32Op.LeS, expr e1, expr e2)
  | Ast.I32_le_u (e1, e2) -> Compare (Int32 I32Op.LeU, expr e1, expr e2)
  | Ast.I32_gt_s (e1, e2) -> Compare (Int32 I32Op.GtS, expr e1, expr e2)
  | Ast.I32_gt_u (e1, e2) -> Compare (Int32 I32Op.GtU, expr e1, expr e2)
  | Ast.I32_ge_s (e1, e2) -> Compare (Int32 I32Op.GeS, expr e1, expr e2)
  | Ast.I32_ge_u (e1, e2) -> Compare (Int32 I32Op.GeU, expr e1, expr e2)
  | Ast.I64_eq (e1, e2) -> Compare (Int64 I64Op.Eq, expr e1, expr e2)
  | Ast.I64_ne (e1, e2) -> Compare (Int64 I64Op.Ne, expr e1, expr e2)
  | Ast.I64_lt_s (e1, e2) -> Compare (Int64 I64Op.LtS, expr e1, expr e2)
  | Ast.I64_lt_u (e1, e2) -> Compare (Int64 I64Op.LtU, expr e1, expr e2)
  | Ast.I64_le_s (e1, e2) -> Compare (Int64 I64Op.LeS, expr e1, expr e2)
  | Ast.I64_le_u (e1, e2) -> Compare (Int64 I64Op.LeU, expr e1, expr e2)
  | Ast.I64_gt_s (e1, e2) -> Compare (Int64 I64Op.GtS, expr e1, expr e2)
  | Ast.I64_gt_u (e1, e2) -> Compare (Int64 I64Op.GtU, expr e1, expr e2)
  | Ast.I64_ge_s (e1, e2) -> Compare (Int64 I64Op.GeS, expr e1, expr e2)
  | Ast.I64_ge_u (e1, e2) -> Compare (Int64 I64Op.GeU, expr e1, expr e2)
  | Ast.F32_eq (e1, e2) -> Compare (Float32 F32Op.Eq, expr e1, expr e2)
  | Ast.F32_ne (e1, e2) -> Compare (Float32 F32Op.Ne, expr e1, expr e2)
  | Ast.F32_lt (e1, e2) -> Compare (Float32 F32Op.Lt, expr e1, expr e2)
  | Ast.F32_le (e1, e2) -> Compare (Float32 F32Op.Le, expr e1, expr e2)
  | Ast.F32_gt (e1, e2) -> Compare (Float32 F32Op.Gt, expr e1, expr e2)
  | Ast.F32_ge (e1, e2) -> Compare (Float32 F32Op.Ge, expr e1, expr e2)
  | Ast.F64_eq (e1, e2) -> Compare (Float64 F64Op.Eq, expr e1, expr e2)
  | Ast.F64_ne (e1, e2) -> Compare (Float64 F64Op.Ne, expr e1, expr e2)
  | Ast.F64_lt (e1, e2) -> Compare (Float64 F64Op.Lt, expr e1, expr e2)
  | Ast.F64_le (e1, e2) -> Compare (Float64 F64Op.Le, expr e1, expr e2)
  | Ast.F64_gt (e1, e2) -> Compare (Float64 F64Op.Gt, expr e1, expr e2)
  | Ast.F64_ge (e1, e2) -> Compare (Float64 F64Op.Ge, expr e1, expr e2)

  | Ast.I32_wrap_i64 e -> Convert (Int32 I32Op.WrapInt64, expr e)
  | Ast.I32_trunc_s_f32 e -> Convert (Int32 I32Op.TruncSFloat32, expr e)
  | Ast.I32_trunc_u_f32 e -> Convert (Int32 I32Op.TruncUFloat32, expr e)
  | Ast.I32_trunc_s_f64 e -> Convert (Int32 I32Op.TruncSFloat64, expr e)
  | Ast.I32_trunc_u_f64 e -> Convert (Int32 I32Op.TruncUFloat64, expr e)
  | Ast.I64_extend_s_i32 e -> Convert (Int64 I64Op.ExtendSInt32, expr e)
  | Ast.I64_extend_u_i32 e -> Convert (Int64 I64Op.ExtendUInt32, expr e)
  | Ast.I64_trunc_s_f32 e -> Convert (Int64 I64Op.TruncSFloat32, expr e)
  | Ast.I64_trunc_u_f32 e -> Convert (Int64 I64Op.TruncUFloat32, expr e)
  | Ast.I64_trunc_s_f64 e -> Convert (Int64 I64Op.TruncSFloat64, expr e)
  | Ast.I64_trunc_u_f64 e -> Convert (Int64 I64Op.TruncUFloat64, expr e)
  | Ast.F32_convert_s_i32 e -> Convert (Float32 F32Op.ConvertSInt32, expr e)
  | Ast.F32_convert_u_i32 e -> Convert (Float32 F32Op.ConvertUInt32, expr e)
  | Ast.F32_convert_s_i64 e -> Convert (Float32 F32Op.ConvertSInt64, expr e)
  | Ast.F32_convert_u_i64 e -> Convert (Float32 F32Op.ConvertUInt64, expr e)
  | Ast.F32_demote_f64 e -> Convert (Float32 F32Op.DemoteFloat64, expr e)
  | Ast.F64_convert_s_i32 e -> Convert (Float64 F64Op.ConvertSInt32, expr e)
  | Ast.F64_convert_u_i32 e -> Convert (Float64 F64Op.ConvertUInt32, expr e)
  | Ast.F64_convert_s_i64 e -> Convert (Float64 F64Op.ConvertSInt64, expr e)
  | Ast.F64_convert_u_i64 e -> Convert (Float64 F64Op.ConvertUInt64, expr e)
  | Ast.F64_promote_f32 e -> Convert (Float64 F64Op.PromoteFloat32, expr e)
  | Ast.I32_reinterpret_f32 e -> Convert (Int32 I32Op.ReinterpretFloat, expr e)
  | Ast.I64_reinterpret_f64 e -> Convert (Int64 I64Op.ReinterpretFloat, expr e)
  | Ast.F32_reinterpret_i32 e -> Convert (Float32 F32Op.ReinterpretInt, expr e)
  | Ast.F64_reinterpret_i64 e -> Convert (Float64 F64Op.ReinterpretInt, expr e)

  | Ast.Memory_size -> Host (MemorySize, [])
  | Ast.Grow_memory e -> Host (GrowMemory, [expr e])
  | Ast.Has_feature s -> Host (HasFeature s, [])

and block = function
  | [] -> Nop @@ Source.no_region
  | es -> Block (List.map label (List.map expr es)) @@@ List.map Source.at es

and opt = function
  | None -> Nop @@ Source.no_region
  | Some e -> Block [label (expr e); Nop @@ e.at] @@ e.at


(* Functions and Modules *)

let rec func f = func' f.it @@ f.at
and func' = function
  | {Ast.body = es; ftype; locals} ->
    {body = block es @@@ List.map at es; ftype; locals}

let rec module_ m = module' m.it @@ m.at
and module' = function
  | {Ast.funcs = fs; start; memory; types; imports; exports; table} ->
    {funcs = List.map func fs; start; memory; types; imports; exports; table}

let desugar = module_
