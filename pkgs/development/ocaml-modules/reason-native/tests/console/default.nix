{
  lib,
  buildDunePackage,
  console,
  ppxlib,
  reason,
}:

buildDunePackage {
  pname = "console_test";
  version = "1";

  src = lib.fileset.toSource {
    fileset = lib.fileset.unions [
      ./console_test.opam
      ./console_test.re
      ./dune
      ./dune-project
    ];

    root = ./.;
  };

  nativeBuildInputs = [
    reason
  ];

  buildInputs = [
    reason
    console
    ppxlib
  ];

  doInstallCheck = true;
  duneVersion = "3";

  postInstallCheck = ''
    $out/bin/console_test | grep -q "{\"Hello fellow Nixer!\"}" > /dev/null
  '';
}
