{
  lib,
  stdenv,
  fetchurl,
  blackbox-terminal,
  cairo,
  darwinMinVersionHook,
  desktop-file-utils,
  fast-float,
  fetchpatch,
  fmt_11,
  fribidi,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gnutls,
  gobject-introspection,
  gperf,
  gtk3,
  gtk4,
  icu,
  libxml2,
  lz4,
  meson,
  ninja,
  nixosTests,
  pango,
  pcre2,
  pkg-config,
  python3,
  simdutf,
  systemd,
  vala,
  gtkVersion ? "3",
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
  withApp ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vte";
  version = "0.84.0";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${lib.versions.majorMinor finalAttrs.version}/vte-${finalAttrs.version}.tar.xz";
    hash = "sha256-BBTjFYODaut4eNol9nxRX36IeZF+zDfJLia4Po2Pw+M=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional (gtkVersion != null) "devdoc";

  patches = [
    # VTE needs a small patch to work with musl:
    # https://gitlab.gnome.org/GNOME/vte/issues/72
    # Taken from https://git.alpinelinux.org/aports/tree/community/vte3
    (fetchpatch {
      hash = "sha256-FkVyhsM0mRUzZmS2Gh172oqwcfXv6PyD6IEgjBhy2uU=";
      name = "0001-Add-W_EXITCODE-macro-for-non-glibc-systems.patch";
      url = "https://git.alpinelinux.org/aports/plain/community/vte3/fix-W_EXITCODE.patch?id=4d35c076ce77bfac7655f60c4c3e4c86933ab7dd";
    })
  ];

  postPatch = ''
    patchShebangs perf/* \
      src/app/meson_desktopfile.py \
      src/parser-seq.py \
      src/minifont-coverage.py \
      src/modes.py
  '';

  nativeBuildInputs = [
    desktop-file-utils # for desktop-file-validate
    gettext
    gobject-introspection
    gperf
    libxml2
    meson
    ninja
    pkg-config
    vala
    python3
    gi-docgen
  ];

  buildInputs = [
    cairo
    fmt_11
    fribidi
    gnutls
    pango # duplicated with propagatedBuildInputs to support gtkVersion == null
    pcre2
    lz4
    icu
    fast-float
    simdutf
  ]
  ++ lib.optionals systemdSupport [
    systemd
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (darwinMinVersionHook "13.3")
  ];

  # Required by vte-2.91.pc.
  propagatedBuildInputs = lib.optionals (gtkVersion != null) [
    (
      assert (gtkVersion == "3" || gtkVersion == "4");
      if gtkVersion == "3" then gtk3 else gtk4
    )
    glib
    pango
  ];

  mesonFlags = [
    "-Ddocs=true"
    (lib.mesonBool "app" withApp)
    (lib.mesonBool "gtk3" (gtkVersion == "3"))
    (lib.mesonBool "gtk4" (gtkVersion == "4"))
    (lib.mesonBool "_systemd" systemdSupport)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # -Bsymbolic-functions is not supported on darwin
    "-D_b_symbolic_functions=false"
  ];

  # error: argument unused during compilation: '-pie' [-Werror,-Wunused-command-line-argument]
  env.NIX_CFLAGS_COMPILE = toString (
    lib.optional stdenv.hostPlatform.isMusl "-Wno-unused-command-line-argument"
    ++ lib.optional stdenv.cc.isClang "-Wno-cast-function-type-strict"
  );

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    tests = {
      inherit (nixosTests.terminal-emulators)
        gnome-terminal
        lxterminal
        mlterm
        roxterm
        sakura
        stupidterm
        terminator
        xfce4-terminal
        ;

      inherit blackbox-terminal;
    };

    updateScript = gnome.updateScript {
      packageName = "vte";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Library implementing a terminal emulator widget for GTK";

    longDescription = ''
      VTE is a library (libvte) implementing a terminal emulator widget for
      GTK, and a minimal sample application (vte) using that.  Vte is
      mainly used in gnome-terminal, but can also be used to embed a
      console/terminal in games, editors, IDEs, etc. VTE supports Unicode and
      character set conversion, as well as emulating any terminal known to
      the system's terminfo database.
    '';

    homepage = "https://www.gnome.org/";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      antono
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
