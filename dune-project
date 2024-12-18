(lang dune 3.16)
  (generate_opam_files true)
  (authors "David" "Emma" "Mia" "Tam")
  (maintainers "elevits2@jhu.edu")
  (package
   (name strands)
   (allow_empty)
   (homepage "none")
   (bug_reports "README")
   (license "AFL-3.0")
   (synopsis "An OCaml project to recreate Strands")
   (description "The purpose of this project is to recreate “Strands”, a word search game by the New York
    Times. Strands feature a 6x8 letter grid where players find words linked by a common theme.
    A unique spangram, a challenge word connecting two opposite board edges, provides a
    major hint to the theme. Themed words highlight in blue, while the spangram appears in
    yellow. Each puzzle must be fully solved with no overlapping words.")
   (depends
    (ounit2 (>= 2.2.7))
    (core (>= 0.17.1))
    (dream (>= 1.0.0))
    (yojson (>= 2.2.2))
 ))
