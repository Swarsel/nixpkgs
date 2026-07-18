# Builds hello-world Factor application using buildFactorApplication & verifies
# source-to-binary that the resulting app prints "Hello, $NAME" depending on
# `--name` flag.
{
  lib,
  buildFactorApplication,
  buildFactorVocab,
  runCommandLocal,
}:

let
  fs = lib.fileset;

  factorFilter =
    file:
    lib.lists.any file.hasExt [
      "factor"
      "txt"
    ];

  version = "0-test";

  vocab = buildFactorVocab {
    inherit version;
    pname = "hello";

    src = fs.toSource {
      fileset = fs.difference (fs.fileFilter factorFilter ./extra/hello) ./extra/hello/cli;
      root = ./extra;
    };

    vocabName = "hello";
  };

  app = buildFactorApplication {
    inherit version;
    pname = "hello-cli";

    src = fs.toSource {
      fileset = fs.fileFilter factorFilter ./extra/hello/cli;
      root = ./extra;
    };

    binName = "hello";
    extraVocabs = [ vocab ];
    vocabName = "hello.cli";
  };
in
runCommandLocal "assert-factor-hello-world"
  {
    env.expected = "Hello, Nixpkgs";
  }
  ''
    output="$(${lib.getExe app} --name "Nixpkgs")"
    if [ "$output" != "$expected" ]; then
      echo "FAIL: expected “$expected”; got “$output”" >&2
      exit 1
    fi
    touch "$out"
  ''
