{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "ceres";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.version [
      (case (range "8.14" "9.2") "0.4.1")
      (case (range "8.8" "8.16") "0.4.0")
    ] null;

  owner = "Lysxia";
  release."0.4.0".hash = "sha256:0zwp3pn6fdj0qdig734zdczrls886al06mxqhhabms0jvvqijmbi";
  release."0.4.1".hash = "sha256-9vyk8/8IVsqNyhw3WPzl8w3L9Wu7gfaMVa3n2nWjFiA=";
  repo = "coq-ceres";
  useDuneifVersion = lib.versions.isGe "0.4.1";

  meta = {
    description = "Library for serialization to S-expressions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zimmi48 ];
  };
}
