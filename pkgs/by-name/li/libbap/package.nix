{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ocaml-ng,
  which,
}:

stdenv.mkDerivation {
  pname = "libbap";
  version = "master-2022-07-13";

  src = fetchFromGitHub {
    owner = "BinaryAnalysisPlatform";
    repo = "bap-bindings";
    rev = "4d324dd794f8e022e8eddecbb2ae2e7b28173947";
    hash = "sha256-la47HR+i99ueDEWR91YIXGdKflpE1E0qmmJjeowmGSI=";
  };

  nativeBuildInputs = [
    autoreconfHook
    which
  ]
  ++ (with ocaml-ng.ocamlPackages_4_14; [
    ocaml
    findlib
  ]);

  buildInputs = with ocaml-ng.ocamlPackages_4_14; [
    bap
    ctypes
    ctypes-foreign
  ];

  preInstall = ''
    mkdir -p $out/lib
    mkdir -p $out/include
  '';

  meta = {
    description = "C library for interacting with BAP";
    homepage = "https://github.com/binaryanalysisplatform/bap-bindings";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.maurer ];
    platforms = lib.platforms.unix;
    broken = true; # Not compatible with JaneStreet libraries 0.17
  };
}
