(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

type t

module Log : sig
  val as_value : t -> Typing_log_value.value
end

val init : t

val get_tyvar_occurrences : t -> Ident.t -> ISet.t

val contains_unsolved_tyvars : t -> Ident.t -> bool

val make_tyvars_occur_in_tyvar : t -> ISet.t -> occur_in:Ident.t -> t

val make_tyvar_no_more_occur_in_tyvar : t -> Ident.t -> no_more_in:int -> t
