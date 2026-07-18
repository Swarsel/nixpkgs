{
  lib,
  ExtLib,
  callPackage,
  coq,
  mkCoqDerivation,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "simple-io";
  nativeBuildInputs = [ coq.ocamlPackages.cppo ];

  propagatedBuildInputs = [
    ExtLib
  ]
  ++ (with coq.ocamlPackages; [
    ocaml
    findlib
    ocamlbuild
  ]);

  doCheck = true;
  checkTarget = "test";

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.coq-version [
      (case (range "8.17" "9.1") "1.11.0")
      (case (range "8.11" "8.19") "1.8.0")
      (case (range "8.7" "8.13") "1.3.0")
    ] null;

  mlPlugin = true;
  owner = "Lysxia";
  release."1.10.0".hash = "sha256-67cBhLvRMWLWBL7NXK1zZTQC4PtSKu9qtesU4SqKkOw=";
  release."1.11.0".hash = "sha256-sgbH7eI4TPHOQ5qBvM6x7G3j8B40HSEMEzFaN1G9VEw=";
  release."1.3.0".hash = "sha256:1yp7ca36jyl9kz35ghxig45x6cd0bny2bpmy058359p94wc617ax";
  release."1.7.0".hash = "sha256:1a1q9x2abx71hqvjdai3n12jxzd49mhf3nqqh3ya2ssl2lj609ci";
  release."1.8.0".hash = "sha256-3ADNeXrBIpYRlfUW+LkLHUWV1w1HFrVc/TZISMuwvRY=";
  repo = "coq-simple-io";
  useDuneifVersion = v: (lib.versionAtLeast v "1.10.0" || v == "dev");
  passthru.tests.HelloWorld = callPackage ./test.nix { };

  meta = {
    description = "Purely functional IO for Coq";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}).overrideAttrs
  (
    o:
    lib.optionalAttrs (lib.versionAtLeast o.version "1.8.0" || o.version == "dev") {
      doCheck = false;
    }
  )
