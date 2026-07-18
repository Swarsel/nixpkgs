{
  lib,
  stdenv,
  fetchurl,
  fsuae,
  gettext,
  libsForQt5,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fs-uae-launcher";
  version = "3.1.70";

  src = fetchurl {
    url = "https://fs-uae.net/files/FS-UAE-Launcher/Stable/${finalAttrs.version}/fs-uae-launcher-${finalAttrs.version}.tar.xz";
    hash = "sha256-yvJ8sa44V13SEUJ6C9SgS+N2ZFH5+20TTL2ICY9A36c=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "distutils.core" "setuptools"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    python3Packages.python
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = with python3Packages; [
    pyqt5
    requests
    setuptools
  ];

  makeFlags = [ "prefix=$(out)" ];

  preFixup = ''
    wrapQtApp "$out/bin/fs-uae-launcher" \
      --set PYTHONPATH "$PYTHONPATH"

    # fs-uae-launcher search side by side for executables and shared files
    # see $src/fsgs/plugins/pluginexecutablefinder.py#find_executable
    ln -s ${fsuae}/bin/fs-uae $out/bin
    ln -s ${fsuae}/bin/fs-uae-device-helper $out/bin
    ln -s ${fsuae}/share/fs-uae $out/share/fs-uae
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Graphical front-end for the FS-UAE emulator";
    homepage = "https://fs-uae.net";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.systems.inspect; patternLogicalAnd patterns.isx86 patterns.isLinux;
    mainProgram = "fs-uae-launcher";
  };
})
