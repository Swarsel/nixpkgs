{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "pocklington";

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.7" "8.18";
        out = "8.12.0";
      }
    ] null;

  owner = "coq-community";
  release."8.12.0".hash = "sha256-0xBrw9+4g14niYdNqp0nx00fPJoSSnaDSDEaIVpPfjs=";
  release."8.12.0".rev = "v8.12.0";

  meta = {
    description = "Pocklington's criterion for primality in Coq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
