{
  lib,
  mkRocqDerivation,
  rocq-core,
  stdlib,
  version ? null,
}:

mkRocqDerivation {
  inherit version;
  pname = "relation-algebra";

  propagatedBuildInputs = [
    stdlib
  ];

  defaultVersion =
    lib.switch
      [ rocq-core.rocq-version ]
      [
        {
          cases = [ (lib.versions.range "9.0" "9.1") ];
          out = "1.8.0";
        }
      ]
      null;

  dontConfigure = true;
  mlPlugin = true;
  owner = "damien-pous";
  release."1.8.0".sha256 = "sha256-RnY+a57KnStACteaT5dKQoCCH0qp7/W+4qoaApIilj0=";
  releaseRev = v: "v${v}";

  meta = {
    description = "Relation algebra library for Rocq";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
