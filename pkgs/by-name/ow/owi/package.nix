{
  lib,
  fetchFromGitHub,
  llvmPackages,
  makeWrapper,
  nixosTests,
  ocaml-ng,
  rustc,
  unstableGitUpdater,
  zig,
}:

let
  ocamlPackages = ocaml-ng.ocamlPackages_5_4;
in
ocamlPackages.buildDunePackage {
  pname = "owi";
  version = "0.2-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "ocamlpro";
    repo = "owi";
    rev = "2d6ec0d897a209f34849d25f8bcfc73298820be3";
    hash = "sha256-A+mTFvojEpIfRPJkPRf5vfHf+nk+3/hdIbJqIDv/AzM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with ocamlPackages; [
    findlib
    menhir
    # unwrapped because wrapped tries to enforce a target and the build
    # script wants to do its own thing
    llvmPackages.clang-unwrapped
    # lld + llc isn't included in unwrapped, so we pull it in here
    llvmPackages.bintools-unwrapped
    makeWrapper
    rustc
    zig
  ];

  buildInputs = with ocamlPackages; [
    dune-build-info
    dune-site
  ];

  propagatedBuildInputs = with ocamlPackages; [
    bos
    cmdliner
    digestif
    domainpc
    menhirLib
    ocaml_intrinsics
    ocamlgraph
    prelude
    processor
    scfg
    sedlex
    smtml
    symex
    synchronizer
    uutf
    xmlm
    yojson
  ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/owi \
      --prefix PATH : ${
        lib.makeBinPath [
          llvmPackages.bintools-unwrapped
          llvmPackages.clang-unwrapped
          rustc
          zig
        ]
      }
  '';

  passthru = {
    tests = { inherit (nixosTests) owi; };
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Symbolic execution for Wasm, C, C++, Rust and Zig";
    homepage = "https://ocamlpro.github.io/owi/";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      ethancedwards8
      redianthus
    ];

    badPlatforms = lib.platforms.darwin;
    mainProgram = "owi";
    downloadPage = "https://github.com/OCamlPro/owi";
    teams = with lib.teams; [ ngi ];
  };
}
