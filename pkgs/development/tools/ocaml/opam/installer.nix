{ ocamlPackages, opam }:

ocamlPackages.buildDunePackage {
  inherit (opam) version src;
  pname = "opam-installer";

  buildInputs = with ocamlPackages; [
    opam-format
    cmdliner
  ];

  configureFlags = [
    "--disable-checks"
    "--prefix=$out"
  ];

  meta = opam.meta // {
    description = "Handle (un)installation from opam install files";
    mainProgram = "opam-installer";
  };
}
