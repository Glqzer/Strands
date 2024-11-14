(lang dune 3.0)
(name strands)
(generate_opam_files true)

(package
 (name strands)
 (depends
  (ocaml (>= 4.14.0))
  (dune (>= 3.0))
  (cohttp-lwt-unix (>= 5.0.0))
  (yojson (>= 2.0.0))
  (lwt (>= 5.6.1))
  (ppx_deriving_yojson (>= 3.7.0))))