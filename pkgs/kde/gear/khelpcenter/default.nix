{
  kio-extras,
  man-db,
  mkKdeDerivation,
  python3,
  qtwebengine,
  replaceVars,
  xapian,
}:
mkKdeDerivation {
  pname = "khelpcenter";

  patches = [
    (replaceVars ./use_nix_paths_for_mansearch_utilities.patch {
      inherit man-db;
    })
  ];

  extraBuildInputs = [
    qtwebengine
    xapian
    python3
    kio-extras
  ];

  meta.mainProgram = "khelpcenter";
}
