{
  lib,
  coq,
  deriving,
  equations,
  extructures,
  mathcomp-analysis,
  mathcomp-boot,
  mathcomp-experimental-reals,
  mathcomp-word,
  mkCoqDerivation,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "ssprove";

  propagatedBuildInputs = [
    equations
    mathcomp-boot
    mathcomp-analysis
    mathcomp-experimental-reals
    extructures
    deriving
    mathcomp-word
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
    with lib.versions;
    lib.switch
      [ coq.coq-version mathcomp-boot.version ]
      [
        (case (range "8.20" "9.1") (range "2.3.0" "2.5.0") "0.3.1")
        (case (range "8.18" "9.1") (range "2.3.0" "2.4.0") "0.2.4")
        (case (range "8.18" "8.20") (range "2.3.0" "2.3.0") "0.2.3")
        (case (range "8.18" "8.20") (range "2.1.0" "2.2.0") "0.2.2")
        # This is the original dependency:
        # (case "8.17" "1.18.0" "0.1.0")
        # But it is not loadable. The math-comp nixpkgs configuration
        # will always only output version 1.18.0 for Coq 8.17.
        # Hence, the Coq 8.17 and math-comp 1.17.0 must be explicitly set
        # to load it.
        # (This version is not on the math-comp CI and hence not checked.)
        (case "8.17" "1.17.0" "0.1.0")
      ]
      null;

  owner = "SSProve";
  release."0.1.0".hash = "sha256-Yj+k+mBsudi3d6bRVlZLyM4UqQnzAX5tHvxtKoIuNTE=";
  release."0.2.0".hash = "sha256-GDkWH0LUsW165vAUoYC5of9ndr0MbfBtmrPhsJVXi3o=";
  release."0.2.1".hash = "sha256-X00q5QFxdcGWeNqOV/PLTOqQyyfqFEinbGUTO7q8bC4=";
  release."0.2.2".hash = "sha256-tBF8equJd6hKZojpe+v9h6Tg9xEnMTVFgOYK7ZnMfxk=";
  release."0.2.3".hash = "sha256-Y3dmNIF36IuIgrVILteofOv8e5awKfq93S4YN7enswI=";
  release."0.2.4".hash = "sha256-uglr47aDgSkKi2JyVyN+2BrokZISZUAE8OUylGjy7ds=";
  release."0.3.0".hash = "sha256-ioPqavLOc8ZEzroalLR4dpqDbnOyzzOmWSF9+J1yPdQ=";
  release."0.3.1".hash = "sha256-KB8cwlU3pnxPMQZ+RSyB2EJINhw7iN3vwF6iY4U4+oc=";
  releaseRev = v: "v${v}";

  meta = {
    description = "SSProve: A Foundational Framework for Modular Cryptographic Proofs in Coq";
    license = lib.licenses.mit;

    maintainers = [
      {
        email = "sebastian.ertel@gmail.com";
        github = "sertel";
        githubId = 3703100;
        name = "Sebastian Ertel";
      }
    ];
  };

})
