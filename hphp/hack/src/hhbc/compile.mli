(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

type result = {
  bytecode_segments: string list;
  parsing_t: float;
  codegen_t: float;
  printing_t: float;
}

type env = {
  filepath: Relative_path.t;
  is_systemlib: bool;
  is_evaled: bool;
  for_debugger_eval: bool;
  dump_symbol_refs: bool;
  config_jsons: Hh_json.json option list;
  config_list: string list;
}

val from_text : string -> env -> result
