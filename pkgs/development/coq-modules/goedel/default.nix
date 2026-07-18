{
  lib,
  coq,
  hydra-battles,
  mkCoqDerivation,
  pocklington,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "goedel";

  propagatedBuildInputs = [
    hydra-battles
    pocklington
  ];

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.11" "8.16";
        out = "8.13.0";
      }
    ] null;

  owner = "coq-community";
  release."8.12.0".hash = "sha256-4lAwWFHGUzPcfHI9u5b+N+7mQ0sLJ8bH8beqQubfFEQ=";
  release."8.13.0".hash = "sha256:0sqqkmj6wsk4xmhrnqkhcsbsrqjzn2gnk67nqzgrmjpw5danz8y5";
  releaseRev = (v: "v${v}");

  meta = {
    description = "Gödel-Rosser 1st incompleteness theorem in Coq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
