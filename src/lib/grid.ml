module type Grid = 
  sig
    type t = char array array
    type position = int * int  
  end


  let init rows cols = Array.make_matrix rows cols ' '

  let get_letter grid (row, col) = grid.(row).(col)

  let set_letter grid (row, col) letter = grid.(row).(col) <- letter




