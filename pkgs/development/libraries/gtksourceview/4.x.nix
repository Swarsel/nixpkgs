{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  dbus,
  fetchpatch2,
  fribidi,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk3,
  libxml2,
  meson,
  ninja,
  pango,
  perl,
  pkg-config,
  shared-mime-info,
  testers,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksourceview";
  version = "4.8.4";

  src =
    let
      inherit (finalAttrs) pname version;
    in
    fetchurl {
      url = "mirror://gnome/sources/gtksourceview/${lib.versions.majorMinor version}/gtksourceview-${version}.tar.xz";
      sha256 = "fsnRj7KD0fhKOj7/O3pysJoQycAGWXs/uru1lYQgqH0=";
    };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # By default, the library loads syntaxes from XDG_DATA_DIRS and user directory
    # but not from its own datadr (it assumes it will be in XDG_DATA_DIRS).
    # Since this is not generally true with Nix, let’s add $out/share unconditionally.
    ./4.x-nix_share_path.patch

    # nix.lang: Add Nix syntax highlighting
    # https://gitlab.gnome.org/GNOME/gtksourceview/-/merge_requests/303
    (fetchpatch2 {
      hash = "sha256-yeYXJ2l/QS857C4UXOnMFyh0JsptA0TQt0lfD7wN5ic=";
      url = "https://gitlab.gnome.org/GNOME/gtksourceview/-/commit/685b3bd08869c2aefe33fad696a7f5f2dc831016.patch";
    })

    # nix.lang: fix section name
    (fetchpatch2 {
      hash = "sha256-6HxLKQyI5DDvmKhmldQlwVPV62RfFa2gwWbcHA2cICs=";
      url = "https://gitlab.gnome.org/GNOME/gtksourceview/-/commit/1dbbb01da98140e0b2d5d0c6c2df29247650ed83.patch";
    })
  ];

  postPatch = ''
    # https://gitlab.gnome.org/GNOME/gtksourceview/-/merge_requests/295
    # build: drop unnecessary vapigen check
    substituteInPlace meson.build \
      --replace "if generate_vapi" "if false"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    perl
    gobject-introspection
    vala
  ];

  buildInputs = [
    atk
    cairo
    glib
    pango
    fribidi
    libxml2
  ];

  propagatedBuildInputs = [
    # Required by gtksourceview-4.0.pc
    gtk3
    # Used by gtk_source_language_manager_guess_language
    shared-mime-info
  ];

  # Broken by PCRE 2 bump in GLib.
  # https://gitlab.gnome.org/GNOME/gtksourceview/-/issues/283
  doCheck = false;

  nativeCheckInputs = [
    xvfb-run
    dbus
  ];

  checkPhase = ''
    runHook preCheck

    XDG_DATA_DIRS="$XDG_DATA_DIRS:${shared-mime-info}/share" \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --no-rebuild --print-errorlogs

    runHook postCheck
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gtksourceview4";
      freeze = true;
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
    pkgConfigModules = [ "gtksourceview-4" ];
    teams = [ lib.teams.gnome ];
  };
})
