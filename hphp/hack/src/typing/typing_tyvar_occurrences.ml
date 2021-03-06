(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

open Common

type t = {
  tyvar_occurrences: ISet.t IMap.t;
      (** A map to track where each type variable occurs,
          more precisely in the type of which other type variables.
          E.g. if #1 is bound to (#2 | int), then this map contains the entry
            #2 -> { #1 }
          This is based on shallow binding, i.e. in the example above, if #2
          is mapped to #3, then tyvar_occurrences would be:
            #2 -> { #1 }
            #3 -> { #2 }
          but we would record that #3 occurs in #1.
          When a type variable v gets solved or the type bound to it gets simplified,
          we simplify the unions and intersections of the types bound to the
          type variables associated to v in this map.
          So in our example, if #2 gets solved to int,
          we simplify #1 to (int | int) = int.
          There are only entries for variables that are unsolved or contain
          other unsolved type variables. Variables that are solved and contain
          no other unsolved type variables get removed from this map. *)
  tyvars_in_tyvar: ISet.t IMap.t;
      (** Mapping of type variables to the type variables contained in their
          types which are either unsolved or themselves contain unsolved type
          variables.
          This is the dual of tyvar_occurrences. *)
}

module Log = struct
  open Typing_log_value

  let iset_imap_as_value map =
    Map
      (IMap.fold
         (fun i vars m -> SMap.add (var_as_string i) (varset_as_value vars) m)
         map
         SMap.empty)

  let tyvar_occurrences_as_value = iset_imap_as_value

  let tyvars_in_tyvar_as_value = iset_imap_as_value

  let as_value x =
    let { tyvar_occurrences; tyvars_in_tyvar } = x in
    make_map
      [
        ("tyvar_occurrences", tyvar_occurrences_as_value tyvar_occurrences);
        ("tyvars_in_tyvar", tyvars_in_tyvar_as_value tyvars_in_tyvar);
      ]
end

let init = { tyvar_occurrences = IMap.empty; tyvars_in_tyvar = IMap.empty }

let get_tyvar_occurrences x v =
  let tyvar_occurrences = x.tyvar_occurrences in
  Option.value (IMap.find_opt v tyvar_occurrences) ~default:ISet.empty

let set_tyvar_occurrences x v vars =
  { x with tyvar_occurrences = IMap.add v vars x.tyvar_occurrences }

(** Make v occur in v', i.e. add v' to the occurrences of v. *)
let add_tyvar_occurrence x v ~occurs_in:v' =
  let vars = get_tyvar_occurrences x v in
  let vars = ISet.add v' vars in
  let x = set_tyvar_occurrences x v vars in
  x

let add_tyvar_occurrences x vars ~occur_in:v =
  ISet.fold (fun v' x -> add_tyvar_occurrence x v' ~occurs_in:v) vars x

let get_tyvars_in_tyvar x v =
  Option.value (IMap.find_opt v x.tyvars_in_tyvar) ~default:ISet.empty

let set_tyvars_in_tyvar x v vars =
  { x with tyvars_in_tyvar = IMap.add v vars x.tyvars_in_tyvar }

let make_tyvars_occur_in_tyvar x vars ~occur_in:v =
  let x = add_tyvar_occurrences x vars ~occur_in:v in
  let x = set_tyvars_in_tyvar x v vars in
  x

let remove_tyvar_occurrence x v ~no_more_occurs_in:v' =
  let vars = get_tyvar_occurrences x v in
  let vars = ISet.remove v' vars in
  let x = set_tyvar_occurrences x v vars in
  x

let remove_tyvar_from_tyvar x ~from:v v' =
  let vars = get_tyvars_in_tyvar x v in
  let vars = ISet.remove v' vars in
  let x = set_tyvars_in_tyvar x v vars in
  x

let make_tyvar_no_more_occur_in_tyvar x v ~no_more_in:v' =
  let x = remove_tyvar_occurrence x v ~no_more_occurs_in:v' in
  let x = remove_tyvar_from_tyvar x ~from:v' v in
  x

let contains_unsolved_tyvars x v =
  not @@ ISet.is_empty (get_tyvars_in_tyvar x v)
