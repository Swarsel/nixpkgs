{
  lib,
  mkRocqDerivation,
  rocq-core,
  stdlib,
  version ? null,
}:

mkRocqDerivation {
  inherit version;
  pname = "parseque";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    lib.switch
      [ rocq-core.rocq-version ]
      [
        {
          cases = [ (lib.versions.range "9.0" "9.2") ];
          out = "0.3.1";
        }
      ]
      null;

  owner = "rocq-community";
  release."0.3.0".sha256 = "sha256-W2eenv5Q421eVn2ubbninFmmdT875f3w/Zs7yGHUKP4=";
  release."0.3.1".sha256 = "sha256-t7nHpHl6E3iXkhMO0A53URmKVpWENjf/VODVXjD9Y1A=";
  releaseRev = v: "v${v}";
  repo = "parseque";

  meta = {
    description = "Total parser combinators in Rocq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ womeier ];
  };
}
