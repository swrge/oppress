import options

type
  # remains to be seen if this sort of aliasing is actually a good idea
  Callable*[T; R] =   (proc(x: T): R {.closure.}) | (proc(x: T): R {.nimcall.}) | (proc(x: T): R {.inline.})

  # compiler is not happy if you don't do this 
  OCallable*[T; R] =  (proc(x: T): Option[R] {.nimcall.}) | (proc(x: T): Option[R] {.closure.}) | (proc(x: T): Option[R] {.inline.})
  VOCallable*[R] =    (proc(): Option[R] {.nimcall.}) | (proc(): Option[R] {.closure.}) | (proc(): Option[R] {.inline.}) 

  UnpackError* = object of CatchableError
