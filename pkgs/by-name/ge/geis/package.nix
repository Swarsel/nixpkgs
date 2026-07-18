{
  lib,
  stdenv,
  fetchurl,
  atk,
  dbus,
  evemu,
  frame,
  gdk-pixbuf,
  gobject-introspection,
  grail,
  gtk3,
  libx11,
  libxext,
  libxi,
  libxtst,
  pango,
  pkg-config,
  python3Packages,
  testers,
  validatePkgConfig,
  wrapGAppsHook3,
  xorg-server,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geis";
  version = "2.2.17";

  src = fetchurl {
    url = "https://launchpad.net/geis/trunk/${finalAttrs.version}/+download/geis-${finalAttrs.version}.tar.xz";
    hash = "sha256-imD1aDhSCUA4kE5pDSPMWpCpgPxS2mfw8oiQuqJccOs=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    python3Packages.wrapPython
    gobject-introspection
    validatePkgConfig
  ];

  buildInputs = [
    atk
    dbus
    evemu
    frame
    gdk-pixbuf
    grail
    gtk3
    libx11
    libxext
    libxi
    libxtst
    pango
    python3Packages.python
    xorg-server
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=misleading-indentation -Wno-error=pointer-compare";

  preFixup = ''
    buildPythonPath "$out ''${pythonPath[*]}"
    gappsWrapperArgs+=(--set PYTHONPATH "$program_PYTHONPATH")
  '';

  hardeningDisable = [ "format" ];

  prePatch = ''
    substituteInPlace python/geis/geis_v2.py --replace-fail \
      "ctypes.util.find_library(\"geis\")" "'$out/lib/libgeis.so'"
    substituteInPlace config.aux/py-compile \
      --replace-fail "import sys, os, py_compile, imp" "import sys, os, py_compile, importlib" \
      --replace-fail "imp." "importlib." \
      --replace-fail "hasattr(imp" "hasattr(importlib"
  '';

  pythonPath = with python3Packages; [ pygobject3 ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = true;
  };

  meta = {
    description = "Library for input gesture recognition";
    homepage = "https://launchpad.net/geis";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libgeis" ];
  };
})
