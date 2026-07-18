{
  lib,
  coq,
  mathcomp-boot,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "autosubst";

  propagatedBuildInputs = [
    mathcomp-boot
    stdlib
  ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.coq-version [
      (case (range "8.14" "9.1") "1.9")
      (case (range "8.14" "8.18") "1.8")
      (case (range "8.10" "8.13") "1.7")
    ] null;

  release."1.7".hash = "sha256-qoyteQ5W2Noxf12uACOVeHhPLvgmTzrvEo6Ts+FKTGI=";
  release."1.8".hash = "sha256-n0lD8D+tjqkDDjFiE4CggxczOPS5TkEnxpB3zEwWZ2I=";
  release."1.9".hash = "sha256-XiLZjMc+1iwRGOstfLm/WQRF6FTdX6oJr5urn3wmLlA=";
  releaseRev = v: "v${v}";

  meta = {
    description = "Automation for de Bruijn syntax and substitution in Coq";
    homepage = "https://www.ps.uni-saarland.de/autosubst/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      siraben
      jwiegley
    ];
  };
}
