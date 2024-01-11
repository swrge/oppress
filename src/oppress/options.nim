{.push raises: [].}

from std/options import Option, UnpackDefect, isSome, isNone, get, none, some, `==`, `$` 
export Option, UnpackDefect, isSome, isNone, get, none, some, `==`, `$`

import ../misc/[typedefs, utils]; export UnpackError
import std/importutils


template Some*[T](val: T): options.Option[T] =
  ## Returns an `Option` that has the value `val`.
  some[T](val)

template None*(T: typedesc): options.Option[T] =
  ## Returns an `Option` for this type that has no value.
  none(T)


proc map*[T, U](self: sink Option[T], cb: Callable[T, U]): Option[U] {.effectsOf: cb.} =
  ## Applies a `cb` function to the value of the `Option` and returns an `Option` containing the new value.
  privateAccess(Option)
  case self.has
  of true:  Some(cb(self.val))
  of false: None(U)

proc map_or*[T, R](self: sink Option[T];
    cb: Callable[T, R];
    default: sink R
  ): R {.effectsOf: cb.} =
  ## Returns the provided default result (if none), or applies a function to the contained value (if any).
  privateAccess(Option)
  case self.has
  of true:  cb(self.val)
  of false: default

proc map_or_else*[T, R](self: sink Option[T];
    cb: Callable[T, R];
    default: Callable[void, R]
  ): R {.effectsOf: cb.} =
  ## Computes a default function result (if none), or applies a different function to the contained value (if any).
  privateAccess(Option)
  case self.has
  of true:  cb(self.val)
  of false: default()

proc `or`*[T](self, opt: sink Option[T]): Option[T] =
  ## Returns `self` if it contains a value, otherwise returns `opt`.
  case self.has
  of true:  self
  of false: opt
  
proc `xor`*[T](self, opt: sink Option[T]): Option[T]  =
  ## Returns one of `self` and `opt` if exactly one of them is Some(T), otherwise returns None.
  if self.has and opt.has.not:
    result = self
  elif self.has.not and opt.has:
    result = opt
  else:
    result = None(T)

proc or_else*[T, R](self: sink Option[T], cb: VOCallable[R]): Option[R] {.effectsOf: cb.} = 
  ## Returns `self` if it contains a value, otherwise calls `cb` and returns it's result.
  case self.has
  of true:  self
  of false: cb()

proc `and`*[T](self, opt: sink Option[T]): Option[T] =
  ## Returns `None` if `self` is `None`, otherwise returns `opt`.
  case self.has
  of true:  opt
  of false: None(T)

proc then*[T](x: bool, cb: Callable[void, T]): Option[T] {.effectsOf: cb.} =
  ## Returns Some(T) if x is true, None() otherwise.
  ## [?] - This is useful to chain against functions that returns a boolean.
  case x
  of true:  Some(cb)
  of false: None(T)

proc and_then*[T, R](self: sink Option[T], cb: OCallable[T, R]): Option[R] {.effectsOf: cb.} =
  ## A renamed version of the std/option's `flatMap` where `self` can be consumed.
  ## If the `Option` has no value, `None` will be returned.
  privateAccess(Option)
  case self.has
  of true:  cb(self.val)
  of false: None(R)

proc then_some*[T](x: bool, val: T): Option[T] =
  ## Returns Some(T) if x is true, None() otherwise. Unlike `then`, you can provide the value directly
  ## [?] - This is useful to chain against functions that returns a boolean.
  case x
  of true:  Some(val)
  of false: None(T)

proc filter*[T](self: sink Option[T], pred: Callable[T, bool]): Option[T] {.effectsOf: pred.} =
  ## Returns None if the option is None, otherwise calls predicate with the wrapped value and returns:
  ## - self if predicate returns true (where T is the wrapped value)
  ## - None(T) if predicate returns false
  privateAccess(Option)
  case (self.has and pred(self.val))
  of true:  self
  of false: None(T)

proc flatten*[T](self: sink Option[Option[T]]): Option[T] =
  privateAccess(Option)
  case self.has
  of true:  self.val
  of false: None(T)

proc zip*[T; R](self: sink Option[T], opt: sink Option[R]): Option[(T, R)] =
  privateAccess(Option)
  case (self.has and opt.has)
  of true:  Some((self.val, opt.val))
  of false: None((T, R))

proc unzip*[T; R](self: sink Option[(T, R)]): (Option[T], Option[R]) =
  privateAccess(Option)
  case self.has
  of true:  (Some(self.val[0]), Some(self.val[1]))
  of false: (None(T), None(R))

proc take*[T](self: sink Option[T]): Option[T] =
  ## Takes the value out of the option, leaving a None in its place.
  ## is a no-op if `self` is already `None`
  result.replace(None(T))

proc take_if*[T](self: sink Option[T], pred: Callable[T, bool]): Option[T] =
  privateAccess(Option)
  case self.has and pred(self.val)
  of true:  take(self)
  of false: self

proc expect*[T](self: Option[T], m = ""): lent T {.raises:[UnpackDefect], discardable.} =
  ## Returns the contained Some(T). This is like `get` but with a message when it raises a Defect.
  ## - If the value is a None(T) this function panics with a message.
  ## - `expect` should be used to describe the reason you expect the Option should be Some.
  ## - [!] This function is discardable, this way you can use it like an `assert` (sort of)
  privateAccess(Option)
  case self.has
  of true:  self.val
  of false: raise (ref UnpackDefect)(msg: m)

proc expect2*[T](self: Option[T], m = ""): lent T {.raises:[UnpackError].} =
  ## Returns the contained Some(T). This is like `get` but stores a message when it raises an Exception.
  ## - [!] Unlike `expect`, this function is NOT discardable. Use this when unpacking a `None(T)` should not be a fatal error.
  privateAccess(Option)
  case self.has
  of true:  self.val
  of false: raise (ref typedefs.UnpackError)(msg: m)

{.pop.}