{
  lib,
  stdenv,
  fetchFromGitLab,
  darwin,
  dune,
  nix-update-script,
  ocamlPackages,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation {

  pname = "acgtk";
  version = "2.2.0";

  src = fetchFromGitLab {
    owner = "acg";
    repo = "dev/acgtk";
    tag = "release-2.2.0";
    hash = "sha256-cDP41a3CHh+KW2PAZ3WTRA2HTXKhb8mMCTNddv6M8Bg=";
    domain = "gitlab.inria.fr";
  };

  strictDeps = true;

  nativeBuildInputs =
    with ocamlPackages;
    [
      dune
      findlib
      menhir
      ocaml
      writableTmpDirAsHomeHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.sigtool ];

  buildInputs = with ocamlPackages; [
    ansiterminal
    cairo2
    cmdliner
    dune-site
    fmt
    logs
    menhirLib
    mtime
    ocamlgraph
    readline
    sedlex
    yojson
  ];

  buildPhase = ''
    runHook preBuild
    dune build -p acgtk --profile=release ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
    runHook postBuild
  '';

  installPhase = ''
    dune install -p acgtk --prefix $out --libdir $OCAMLFIND_DESTDIR
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^release-(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    inherit (ocamlPackages.ocaml.meta) platforms;
    description = "Toolkit for developing ACG signatures and lexicon";
    homepage = "https://acg.loria.fr/";
    license = lib.licenses.cecill20;
    maintainers = with lib.maintainers; [ tournev ];
  };
}
