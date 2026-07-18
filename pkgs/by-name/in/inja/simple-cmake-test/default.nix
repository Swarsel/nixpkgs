{
  lib,
  stdenv,
  cmake,
  inja,
}:

stdenv.mkDerivation {
  src = lib.fileset.toSource {
    fileset = lib.fileset.unions [
      ./main.cpp
      ./CMakeLists.txt
    ];

    root = ./.;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ inja ];
  doInstallCheck = true;

  installCheckPhase = ''
    if [[ `$out/bin/simple-cmake-test` != "Hello world!" ]]; then
      echo "ERROR: $out/bin/simple-cmake-test does not output 'Hello world!'"
      exit 1
    fi
  '';

  name = "inja-simple-cmake-test";
  meta.timeout = 30;
}
