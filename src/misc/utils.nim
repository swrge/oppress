

proc replace*[T](x: var T, y: sink T): T =
  ## like `swap` but returns the swapped value 
  swap(x, y)  
  result = x