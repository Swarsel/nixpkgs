{
  lib,
  stdenv,
  fetchurl,
  dbus,
  fribidi,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk4,
  libxml2,
  meson,
  ninja,
  pango,
  pcre2,
  perl,
  pkg-config,
  shared-mime-info,
  testers,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksourceview";
  version = "5.20.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gtksourceview/${lib.versions.majorMinor finalAttrs.version}/gtksourceview-${finalAttrs.version}.tar.xz";
    hash = "sha256-44vNI/UrhurfD+TYveaY46jKECMiuLTPGlGsKUpEjBs=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # By default, the library loads syntaxes from XDG_DATA_DIRS and user directory
    # but not from its own datadr (it assumes it will be in XDG_DATA_DIRS).
    # Since this is not generally true with Nix, let’s add $out/share unconditionally.
    ./4.x-nix_share_path.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    perl
    gobject-introspection
    vala
    gi-docgen
    gtk4 # for gtk4-update-icon-cache checked during configure
  ];

  buildInputs = [
    glib
    pcre2
    pango
    fribidi
    libxml2
  ];

  propagatedBuildInputs = [
    # Required by gtksourceview-5.0.pc
    gtk4
    # Used by gtk_source_language_manager_guess_language
    shared-mime-info
  ];

  mesonFlags = [
    "-Ddocumentation=true"
  ];

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    xvfb-run
    dbus
  ];

  checkPhase = ''
    runHook preCheck

    env \
      XDG_DATA_DIRS="$XDG_DATA_DIRS:${shared-mime-info}/share" \
      GTK_A11Y=none \
      xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
        --config-file=${dbus}/share/dbus-1/session.conf \
        meson test --no-rebuild --print-errorlogs

    runHook postCheck
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gtksourceview5";
      packageName = "gtksourceview";
      versionPolicy = "odd-unstable";
    };
  };

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Source code editing widget for GTK";
    homepage = "https://gitlab.gnome.org/GNOME/gtksourceview";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "gtksourceview-5" ];
    teams = [ lib.teams.gnome ];
  };
})
