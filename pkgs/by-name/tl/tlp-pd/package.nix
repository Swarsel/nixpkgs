{
  lib,
  coreutils,
  python3Packages,
  tlp,
}:

python3Packages.buildPythonApplication {
  inherit (tlp)
    version
    src
    patches
    postPatch
    ;

  pname = "tlp-pd";
  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  checkPhase = ''
    runHook preCheck

    # The program will error out but at least we are not missing python deps
    ($out/bin/tlpctl --help 2>&1 || true) |\
      grep -q 'g-io-error-quark: Could not connect: No such file or directory'
    $out/bin/tlp-pd --help

    runHook postCheck
  '';

  postInstall = ''
    substituteInPlace $out/share/dbus-1/system-services/*.service \
      --replace-fail "/bin/false" "${coreutils}/false"
  '';

  dependencies = with python3Packages; [
    pygobject3
    dbus-python
  ];

  installTargets = [
    "install-pd"
    "install-man-pd"
  ];

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ tlp ]}" ];
  pyproject = false; # Built with make

  meta = {
    inherit (tlp.meta)
      homepage
      changelog
      platforms
      maintainers
      license
      ;

    description = "Power-profiles-daemon like DBus interface for TLP";
    mainProgram = "tlp-pd";
  };
}
