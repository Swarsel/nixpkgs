{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  cppo,
  dune-configurator,
  findlib,
  graphics,
  lablgtk,
  stdio,
}:

buildDunePackage (finalAttrs: {
  pname = "camlimages";
  version = "5.0.5";

  src = fetchFromGitLab {
    owner = "camlspotter";
    repo = "camlimages";
    rev = finalAttrs.version;
    hash = "sha256-/Dkj8IBVPjGCJCXrLOuJtuaa+nD/a9e8/N+TN9ukw4k=";
  };

  # stdio v0.17 compatibility
  patches = [ ./camlimages.patch ];
  nativeBuildInputs = [ cppo ];

  buildInputs = [
    dune-configurator
    findlib
    graphics
    lablgtk
    stdio
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "OCaml image processing library";
    license = lib.licenses.lgpl2;

    maintainers = [
      lib.maintainers.vbgl
      lib.maintainers.mt-caret
    ];

    branch = "5.0";
  };
})
