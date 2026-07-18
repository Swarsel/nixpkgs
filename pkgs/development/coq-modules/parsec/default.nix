{
  lib,
  ExtLib,
  ceres,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "parsec";

  propagatedBuildInputs = [
    ceres
    ExtLib
  ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.version [
      (case (range "8.14" "9.1") "0.2.0")
      (case (range "8.14" "8.20") "0.1.2")
      (case (range "8.12" "8.16") "0.1.1")
      (case (range "8.12" "8.13") "0.1.0")
    ] null;

  owner = "liyishuai";
  release."0.1.0".hash = "sha256:01avfcqirz2b9wjzi9iywbhz9szybpnnj3672dgkfsimyg9jgnsr";
  release."0.1.1".hash = "sha256:1c0l18s68pzd4c8i3jimh2yz0pqm4g38pca4bm7fr18r8xmqf189";
  release."0.1.2".hash = "sha256-QN0h1CsX86DQBDsluXLtNUvMh3r60/0iDSbYam67AhA=";
  release."0.2.0".hash = "sha256-hM6LVFQ2VQ42QeHu8Ex+oz1VvJUr+g8/nZN+bYHEljQ=";
  releaseRev = (v: "v${v}");
  repo = "coq-parsec";
  useDuneifVersion = v: lib.versions.isGe "0.2.0" v || v == "dev";

  meta = {
    description = "Library for serialization to S-expressions";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Zimmi48 ];
  };
}
