{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ocamlPackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coccinelle";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "coccinelle";
    repo = "coccinelle";
    rev = finalAttrs.version;
    hash = "sha256-ZNWuloXhAXWNNoVWLOuDbC3e6KNL7nzM2346tB04qXA=";
  };

  postPatch = ''
    # Ensure dependencies from Nixpkgs are picked up.
    rm -rf bundles/
  '';

  strictDeps = true;

  nativeBuildInputs = with ocamlPackages; [
    autoreconfHook
    pkg-config
    ocaml
    findlib
    menhir
  ];

  buildInputs = with ocamlPackages; [
    ocaml_pcre
    parmap
    pyml
    stdcompat
  ];

  meta = {
    description = "Program to apply semantic patches to C code";

    longDescription = ''
      Coccinelle is a program matching and transformation engine which
      provides the language SmPL (Semantic Patch Language) for
      specifying desired matches and transformations in C code.
      Coccinelle was initially targeted towards performing collateral
      evolutions in Linux.  Such evolutions comprise the changes that
      are needed in client code in response to evolutions in library
      APIs, and may include modifications such as renaming a function,
      adding a function argument whose value is somehow
      context-dependent, and reorganizing a data structure.  Beyond
      collateral evolutions, Coccinelle is successfully used (by us
      and others) for finding and fixing bugs in systems code.
    '';

    homepage = "https://coccinelle.gitlabpages.inria.fr/website/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.unix;
  };
})
