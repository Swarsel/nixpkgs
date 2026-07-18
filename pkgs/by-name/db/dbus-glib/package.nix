{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  dbus,
  expat,
  gettext,
  glib,
  libiconv,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dbus-glib";
  version = "0.114";

  src = fetchurl {
    url = "${finalAttrs.meta.homepage}/releases/dbus-glib/dbus-glib-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-wJxcCFsqDjkbjufXg6HWP+RE6WcXzBgU1htej8KCenw=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    glib
  ];

  buildInputs = [
    expat
    libiconv
  ];

  propagatedBuildInputs = [
    dbus
    glib
  ];

  configureFlags = [
    "--exec-prefix=${placeholder "dev"}"
  ]
  ++ lib.optional (
    stdenv.buildPlatform != stdenv.hostPlatform
  ) "--with-dbus-binding-tool=${buildPackages.dbus-glib.dev}/bin/dbus-binding-tool";

  doCheck = false;
  outputBin = "dev";
  passthru = { inherit dbus glib; };

  meta = {
    description = "Obsolete glib bindings for D-Bus lightweight IPC mechanism";
    homepage = "https://dbus.freedesktop.org";

    license = with lib.licenses; [
      afl21
      gpl2Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "dbus-binding-tool";
  };
})
