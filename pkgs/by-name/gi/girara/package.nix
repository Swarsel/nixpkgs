{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  dbus,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  json-glib,
  libiconv,
  libintl,
  meson,
  ninja,
  pkg-config,
  xvfb-run,
  zathura,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "girara";
  version = "2026.02.04";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "girara";
    tag = finalAttrs.version;
    hash = "sha256-wTVgldfo8pWdY244nNldiogioijv/k32w1A8pEqOTRE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    check
    dbus
    glib # for glib-compile-resources
  ];

  buildInputs = [
    libintl
    libiconv
    json-glib
  ];

  propagatedBuildInputs = [
    glib
    gtk3
  ];

  mesonFlags = [
    "-Ddocs=disabled" # docs do not seem to be installed
    (lib.mesonEnable "tests" (
      (stdenv.buildPlatform.canExecute stdenv.hostPlatform) && (!stdenv.hostPlatform.isDarwin)
    ))
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = ''
    export NO_AT_BRIDGE=1
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --print-errorlogs
  '';

  passthru = {
    tests = {
      inherit zathura;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "User interface library";

    longDescription = ''
      girara is a library that implements a GTK based VIM-like user interface
      that focuses on simplicity and minimalism.
    '';

    homepage = "https://pwmt.org/projects/girara";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
