{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  dbus,
  glib,
  gobject-introspection,
  libnl,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neard";
  version = "0.20";

  src = fetchFromGitHub {
    owner = "linux-nfc";
    repo = "neard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ty2jXaSuaI+ZuRBSpdh36Yi3V5nd8jGI43Jc9cLkMW4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs test/*
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    gobject-introspection
    pkg-config
    python3Packages.wrapPython
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus
    glib
    libnl
  ];

  configureFlags = [
    "--enable-pie"
    "--enable-test"
    "--enable-tools"
    "--with-sysconfdir=/etc"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  doCheck = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    wrapPythonProgramsIn "$out/lib/neard" "''${pythonPath[*]}"
  '';

  dontWrapGApps = true;
  enableParallelBuilding = true;

  pythonPath = with python3Packages; [
    pygobject3
    dbus-python
  ];

  meta = {
    description = "Near Field Communication manager";
    homepage = "https://01.org/linux-nfc";
    changelog = "https://github.com/linux-nfc/neard/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
