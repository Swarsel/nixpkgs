{
  lib,
  coq,
  metacoq,
  mkCoqDerivation,
  which,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "ElmExtraction";
  postPatch = "patchShebangs ./tests/process-extraction-examples.sh";

  propagatedBuildInputs = [
    coq.ocamlPackages.findlib
    metacoq
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
      [
        coq.coq-version
        metacoq.version
      ]
      [
        (case (lib.versions.range "8.17" "9.0") (lib.versions.range "1.3.1" "1.3.4") "0.1.1")
      ]
      null;

  domain = "github.com";
  owner = "AU-COBRA";
  release."0.1.0".hash = "sha256:EWjubBHsxAl2HuRAfJI3B9qzP2mj89eh0CUc8y7/7Ds=";
  release."0.1.1".hash = "sha256:SDSyXqtOQlW9m9yH8OC909fsC/ePhKkSiY+BoQE76vk=";
  releaseRev = v: "v${v}";
  repo = "coq-elm-extraction";

  meta = {
    description = "Framework for extracting Coq programs to Elm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _4ever2 ];
  };
}
