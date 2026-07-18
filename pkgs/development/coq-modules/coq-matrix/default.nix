{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:
mkCoqDerivation {
  inherit version;
  pname = "CoqMatrix";

  defaultVersion =
    with lib.versions;
    lib.switch coq.version [
      {
        case = range "8.11" "8.18";
        out = "1.0.6";
      }
    ] null;

  owner = "zhengpushi";

  release = {
    "1.0.6".hash = "sha256-XsM3fSstvB6GE5OqT7CFro+RWiYEgJsoQ5gXd74VaK0=";
  };

  meta = {
    description = "Matrix math";
    homepage = "https://github.com/zhengpushi/CoqMatrix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ damhiya ];
  };
}
