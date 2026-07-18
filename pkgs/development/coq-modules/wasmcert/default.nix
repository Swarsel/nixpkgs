{
  lib,
  ExtLib,
  callPackage,
  compcert,
  coq,
  flocq,
  mathcomp-boot,
  mkCoqDerivation,
  parseque,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "wasm";

  buildInputs = [
    coq.ocamlPackages.mdx
    coq.ocamlPackages.linenoise
    coq.ocamlPackages.wasm
  ];

  propagatedBuildInputs = [
    ExtLib
    mathcomp-boot
    parseque
    flocq
    compcert
  ];

  defaultVersion =
    let
      case = coq: mc: out: {
        inherit out;

        cases = [
          coq
          mc
        ];
      };
    in
    lib.switch
      [ coq.coq-version mathcomp-boot.version ]
      [
        (case (lib.versions.range "8.20" "9.1") (lib.versions.isGe "2.4") "2.2.0")
      ]
      null;

  mlPlugin = true;
  owner = "WasmCert";
  release."2.1.0".hash = "sha256-k094mxDLLeelYP+ABm+dm6Y5YrachrbhNeZhfwLHNRo=";
  release."2.2.0".hash = "sha256-GsfNpXgCG6XGqDE+bekzwZsWIHyjDTzWRuNnjCtS/88=";
  releaseRev = v: "v${v}";
  repo = "WasmCert-Coq";
  useDune = true;
  passthru.tests.HelloWorld = callPackage ./test.nix { };

  meta = {
    description = "Wasm mechanisation in Coq/Rocq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ womeier ];
  };
}
