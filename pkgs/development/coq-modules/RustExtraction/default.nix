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
  pname = "RustExtraction";

  postPatch = ''
    patchShebangs ./process_extraction.sh
    patchShebangs ./tests/process-extraction-examples.sh
  '';

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
      inherit (lib.versions) range;
    in
    lib.switch
      [
        coq.coq-version
        metacoq.version
      ]
      [
        (case (range "8.20" "9.0") (range "1.3.2" "1.3.4") "0.1.1")
        (case (range "8.17" "8.19") (range "1.3.1" "1.3.3") "0.1.0")
      ]
      null;

  domain = "github.com";
  mlPlugin = true;
  owner = "AU-COBRA";
  release."0.1.0".hash = "sha256:+Of/DP2Vjsa7ASKswjlvqqhcmDhC9WrozridedNZQkY=";
  release."0.1.1".hash = "sha256:CPZ5J9knJ1aYoQ7RQN8YFSpxqJXjgQaxIA4F8G6X4tM=";
  releaseRev = v: "v${v}";
  repo = "coq-rust-extraction";

  meta = {
    description = "Framework for extracting Coq programs to Rust";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _4ever2 ];
  };
}
