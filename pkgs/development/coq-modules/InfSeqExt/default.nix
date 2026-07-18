{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "InfSeqExt";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.version [
      (case (range "8.9" "9.2") "20230107")
      (case (range "8.5" "8.16") "20200131")
    ] null;

  owner = "DistributedComponents";
  release."20200131".hash = "sha256:0xylkdmb2dqnnqinf3pigz4mf4zmczcbpjnn59g5g76m7f2cqxl0";
  release."20200131".rev = "203d4c20211d6b17741f1fdca46dbc091f5e961a";
  release."20230107".hash = "sha256-YMBzVIsLkIC+w2TeyHrKe29eWLIxrH3wIMZqhik8p9I=";
  release."20230107".rev = "601e89ec019501c48c27fcfc14b9a3c70456e408";
}
