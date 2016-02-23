rem Auto-generated from Makefile!
set NAME=wasm
if '%1' neq '' set NAME=%1
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/float.cmo spec/float.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/numerics.cmi spec/numerics.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/int.cmo spec/int.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/f32.cmo spec/f32.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/f64.cmo spec/f64.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/i32.cmo spec/i32.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/i64.cmo spec/i64.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/types.cmo spec/types.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/values.cmo spec/values.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/memory.cmi spec/memory.mli
ocamlc.opt -c -bin-annot -I given -I spec -I host -o given/source.cmi given/source.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/kernel.cmo spec/kernel.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/ast.cmo spec/ast.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/eval.cmi spec/eval.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/script.cmi host/script.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/binary.cmi spec/binary.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/builtins.cmi host/builtins.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/check.cmi spec/check.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/flags.cmo host/flags.ml
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/sexpr.cmi host/sexpr.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/main.cmo host/main.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/main.d.cmo host/main.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/error.cmi spec/error.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/f32_convert.cmi spec/f32_convert.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/f64_convert.cmi spec/f64_convert.mli
ocamlc.opt -c -bin-annot -I given -I spec -I host -o given/lib.cmi given/lib.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/print.cmi host/print.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/arithmetic.cmi spec/arithmetic.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/desugar.cmi spec/desugar.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/params.cmo host/params.ml
ocamlyacc host/parser.mly
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/parser.cmi host/parser.mli
ocamlc.opt -c -bin-annot -I host -I spec -I given -o host/lexer.cmi host/lexer.mli
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/binary.d.cmo spec/binary.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/builtins.d.cmo host/builtins.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/check.d.cmo spec/check.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/eval.d.cmo spec/eval.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/flags.d.cmo host/flags.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/script.d.cmo host/script.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/sexpr.d.cmo host/sexpr.ml
ocamlc.opt -c -g -bin-annot -I given -I spec -I host -o given/source.d.cmo given/source.ml
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/i32_convert.cmi spec/i32_convert.mli
ocamlc.opt -c -bin-annot -I spec -I host -I given -o spec/i64_convert.cmi spec/i64_convert.mli
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/ast.d.cmo spec/ast.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/error.d.cmo spec/error.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/f32_convert.d.cmo spec/f32_convert.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/f64_convert.d.cmo spec/f64_convert.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/kernel.d.cmo spec/kernel.ml
ocamlc.opt -c -g -bin-annot -I given -I spec -I host -o given/lib.d.cmo given/lib.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/memory.d.cmo spec/memory.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/types.d.cmo spec/types.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/f32.d.cmo spec/f32.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/f64.d.cmo spec/f64.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/i32.d.cmo spec/i32.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/i64.d.cmo spec/i64.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/float.d.cmo spec/float.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/int.d.cmo spec/int.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/numerics.d.cmo spec/numerics.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/values.d.cmo spec/values.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/i32_convert.d.cmo spec/i32_convert.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/i64_convert.d.cmo spec/i64_convert.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/print.d.cmo host/print.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/arithmetic.d.cmo spec/arithmetic.ml
ocamlc.opt -c -g -bin-annot -I spec -I host -I given -o spec/desugar.d.cmo spec/desugar.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/params.d.cmo host/params.ml
ocamllex.opt -q host/lexer.mll
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/lexer.d.cmo host/lexer.ml
ocamlc.opt -c -g -bin-annot -I host -I spec -I given -o host/parser.d.cmo host/parser.ml
ocamlc.opt str.cma bigarray.cma -g given/source.d.cmo given/lib.d.cmo spec/float.d.cmo spec/f32.d.cmo spec/f64.d.cmo spec/numerics.d.cmo spec/int.d.cmo spec/i64.d.cmo spec/types.d.cmo spec/i32.d.cmo spec/values.d.cmo spec/memory.d.cmo spec/kernel.d.cmo host/print.d.cmo spec/error.d.cmo spec/i32_convert.d.cmo spec/f32_convert.d.cmo spec/i64_convert.d.cmo spec/f64_convert.d.cmo spec/arithmetic.d.cmo spec/eval.d.cmo host/builtins.d.cmo host/flags.d.cmo host/params.d.cmo spec/ast.d.cmo spec/check.d.cmo spec/desugar.d.cmo host/script.d.cmo host/parser.d.cmo host/lexer.d.cmo host/sexpr.d.cmo spec/binary.d.cmo host/main.d.cmo -o %NAME%
