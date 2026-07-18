{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
  odoc,
}:
buildDunePackage rec {
  pname = "wasm";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "WebAssembly";
    repo = "spec";
    tag = "opam-${version}";
    hash = "sha256-RbVGW6laC3trP6IhtA2tLrAYVbx0Oucox9FgoEvs6LQ=";
  };

  nativeBuildInputs = [
    menhir
    odoc
  ];

  minimalOCamlVersion = "4.12";

  postUnpack = ''
    cd "$sourceRoot/interpreter"
    export sourceRoot=$PWD
  '';

  meta = {
    description = "Library to read and write WebAssembly (Wasm) files and manipulate their AST";
    homepage = "https://github.com/WebAssembly/spec/tree/main/interpreter";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "wasm";
  };
}
