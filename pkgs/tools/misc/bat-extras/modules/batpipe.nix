{
  lib,
  stdenv,
  buildBatExtrasPkg,
  less,
  procps,
}:
buildBatExtrasPkg {
  patches = [
    ../patches/batpipe-skip-outdated-test.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    ../patches/batpipe-skip-detection-tests.patch
  ];

  dependencies = [
    less
    procps
  ];

  name = "batpipe";

  shellInit = {
    flags = [ ];
  };

  meta.description = "Less (and soon bat) preprocessor for viewing more types of files in the terminal";
}
