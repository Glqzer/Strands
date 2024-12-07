open Grid
open Words

module Game : sig
  type state = {
  board: Grid.t;  
  word_coords: WordCoords.t;  
  word_records: WordRecord.t; 
 }

  (** [initialize_game state] initializes the game state *)
  val initialize_game : state -> state

  (** [check_word word coords state] checks if a given word at the specified
    coordinates matches the valid words on the board*)
  val check_word : string -> (int * int ) list -> state -> bool

  (** [set_found word state] updates the game state to mark the given word as found *)
  val set_found : string -> state -> state
end