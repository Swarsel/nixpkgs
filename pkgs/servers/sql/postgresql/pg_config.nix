{
  lib,
  stdenv,
  diffutils,
  # PostgreSQL package
  finalPackage,
  # PostgreSQL package's outputs
  outputs,
  replaceVarsWith,
  runtimeShell,
}:

replaceVarsWith {
  src = ./pg_config.sh;

  nativeCheckInputs = [
    diffutils
  ];

  # The expected output only matches when outputs have *not* been altered by postgresql.withPackages.
  postCheck = lib.optionalString (outputs.out == lib.getOutput "out" finalPackage) ''
    if [ -e ${lib.getDev finalPackage}/nix-support/pg_config.expected ]; then
        diff ${lib.getDev finalPackage}/nix-support/pg_config.expected <($out/bin/pg_config)
    fi
  '';

  dir = "bin";
  isExecutable = true;
  name = "pg_config";

  replacements = {
    inherit runtimeShell;

    "pg_config.env" = replaceVarsWith {
      src = "${lib.getDev finalPackage}/nix-support/pg_config.env";
      name = "pg_config.env";
      replacements = outputs;
    };
  };
}
