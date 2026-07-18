{
  lib,
  stdenv,
  fetchurl,
  cairo,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gperf,
  gtk4,
  json-glib,
  libsoup_3,
  libsysprof-capture,
  meson,
  ninja,
  pkg-config,
  protobufc,
  sqlite,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libshumate";
  version = "1.6.2";

  src = fetchurl {
    url = "mirror://gnome/sources/libshumate/${lib.versions.majorMinor finalAttrs.version}/libshumate-${finalAttrs.version}.tar.xz";
    hash = "sha256-IjZLuY+LUgM0M2q4IkAZagljSJuGpbODKOG+orZPOp4=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gi-docgen
    meson
    ninja
    pkg-config
    vala
    gobject-introspection
    gperf
  ];

  buildInputs = [
    glib
    cairo
    sqlite
    libsoup_3
    gtk4
    libsysprof-capture
    json-glib
    protobufc
  ];

  mesonFlags = [
    "-Ddemos=true"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    env \
      HOME="$TMPDIR" \
      GTK_A11Y=none \
      xvfb-run meson test --print-errorlogs

    runHook postCheck
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput share/doc/libshumate-1.0 "$devdoc"
  '';

  depsBuildBuild = [
    # required to find native gi-docgen when cross compiling
    pkg-config
  ];

  outputBin = "devdoc"; # demo app

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libshumate";
    };
  };

  meta = {
    description = "GTK toolkit providing widgets for embedded maps";
    homepage = "https://gitlab.gnome.org/GNOME/libshumate";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "shumate-demo";
    teams = [ lib.teams.gnome ];
  };
})
