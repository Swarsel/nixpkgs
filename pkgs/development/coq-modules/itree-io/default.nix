{
  lib,
  ITree,
  coq,
  mkCoqDerivation,
  simple-io,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "itree-io";

  propagatedBuildInputs = [
    ITree
    simple-io
  ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      (case (range "8.12" "8.19") "0.1.1")
    ] null;

  owner = "Lysxia";

  release = {
    "0.1.1".hash = "sha256-IFwIj8dxW4jm2gvuUJ8LKZFSJeljp0bsn8fezxY6t2o=";
  };

  releaseRev = v: "v${v}";
  repo = "coq-itree-io";

  meta = {
    description = "Interpret itree in the IO monad of simple-io";
    license = lib.licenses.mit;
  };
}
