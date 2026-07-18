{
  lib,
  stdenv,
  alcotest,
  buildDunePackage,
  conan-database,
  conan-unix,
  crowbar,
  darwin,
  dune-site,
  fmt,
  rresult,
}:

buildDunePackage {
  inherit (conan-unix) version src meta;
  pname = "conan-cli";

  buildInputs = [
    conan-unix
    dune-site
  ];

  doCheck = true;

  nativeCheckInputs = [
    conan-database
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool # codesign
  ];

  checkInputs = [
    alcotest
    conan-database
    crowbar
    fmt
    rresult
  ];

  preCheck = ''
    export DUNE_CACHE=disabled
  '';
}
