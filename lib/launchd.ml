(*
 * Copyright (c) 2015 Unikernel Systems
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)


 type error = [
 | `Enoent of string
 | `Esrch
 | `Ealready
 ]

 type 'a result = ('a, error) Result.result

let error_to_msg = function
  | Result.Ok x -> Result.Ok x
  | Result.Error (`Enoent x) -> Result.Error (`Msg ("There was no socket named " ^ x))
  | Result.Error `Esrch -> Result.Error (`Msg "This process is not managed by launchd")
  | Result.Error `Ealready -> Result.Error (`Msg "The socket has already been activated")

module LowLevel = struct
  external launch_activate_socket: string -> Unix.file_descr array = "stub_launch_activate_socket"
end

let activate_socket name =
  try
    Result.Ok (Array.to_list (LowLevel.launch_activate_socket name))
  with Unix.Unix_error(Unix.ENOENT, _, _) ->
    Result.Error (`Enoent name)
  | Unix.Unix_error(Unix.ESRCH, _, _) ->
    Result.Error `Esrch
  | Unix.Unix_error(Unix.EALREADY, _, _) ->
    Result.Error `Ealready
