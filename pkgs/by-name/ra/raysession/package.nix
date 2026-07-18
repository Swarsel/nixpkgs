{
  lib,
  fetchurl,
  bash,
  libjack2,
  python3Packages,
  qt5,
  which,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "raysession";
  version = "0.14.4";

  src = fetchurl {
    url = "https://github.com/Houston4444/RaySession/releases/download/v${finalAttrs.version}/RaySession-${finalAttrs.version}-source.tar.gz";
    hash = "sha256-cr9kqZdqY6Wq+RkzwYxNrb/PLFREKUgWeVNILVUkc7A=";
  };

  postPatch = ''
    # Fix installation path of xdg schemas.
    substituteInPlace Makefile --replace '$(DESTDIR)/' '$(DESTDIR)$(PREFIX)/'
    # Do not wrap an importable module with a shell script.
    chmod -x src/daemon/desktops_memory.py
    chmod -x src/clients/jackpatch/main_loop.py
  '';

  nativeBuildInputs = [
    python3Packages.pyqt5 # pyuic5 and pyrcc5 to build resources.
    qt5.qttools # lrelease to build translations.
    which # which to find lrelease.
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    libjack2
    bash
  ];

  postFixup = ''
    wrapPythonProgramsIn "$out/share/raysession/src" "$out ''${pythonPath[*]}"
    for file in $out/bin/*; do
      wrapQtApp "$file"
    done
  '';

  dependencies = [
    python3Packages.pyliblo3
    python3Packages.pyqt5
  ];

  dontWrapQtApps = true; # The program is a python script.
  installFlags = [ "PREFIX=$(out)" ];

  makeWrapperArgs = [
    "--suffix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [ libjack2 ])
  ];

  pyproject = false;

  meta = {
    description = "Session manager for Linux musical programs";
    homepage = "https://github.com/Houston4444/RaySession";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
