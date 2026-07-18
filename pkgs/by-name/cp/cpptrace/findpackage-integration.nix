{
  lib,
  stdenv,
  checkOutput,
  cmake,
  cpptrace,
  src,
  static,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit src;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    (cpptrace.override { inherit static; })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install main $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = lib.strings.concatLines (
    [ "$out/bin/main" ]
    # Check that the backtrace contains the path to the executable.
    ++ lib.optionals checkOutput [
      ''
        if [[ !(`$out/bin/main 2>&1` =~ "${finalAttrs.name}") ]]; then
          echo "ERROR: $out/bin/main does not output '${finalAttrs.name}'"
          exit 1
        fi
      ''
    ]
  );

  name = "cpptrace-findpackage-integration-test";
})
