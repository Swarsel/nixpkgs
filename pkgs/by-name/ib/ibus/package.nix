{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  cldr-annotations,
  dbus,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk3,
  gtk4,
  isocodes,
  json-glib,
  libdbusmenu-gtk3,
  libx11,
  libxkbcommon,
  makeWrapper,
  nix-update-script,
  nixosTests,
  pkg-config,
  python3,
  replaceVars,
  runCommand,
  runtimeShell,
  systemd,
  unicode-character-database,
  unicode-emoji,
  vala,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsHook3,
  dconf ? null,
  enableUI ? !libOnly,
  libOnly ? false,
  libnotify ? null,
  withWayland ? !libOnly,
}:

let
  python3Runtime = python3.withPackages (ps: with ps; [ pygobject3 ]);
  python3BuildEnv = python3.pythonOnBuildForHost.buildEnv.override {
    # ImportError: No module named site
    postBuild = ''
      makeWrapper ${glib.dev}/bin/gdbus-codegen $out/bin/gdbus-codegen --unset PYTHONPATH
      makeWrapper ${glib.dev}/bin/glib-genmarshal $out/bin/glib-genmarshal --unset PYTHONPATH
      makeWrapper ${glib.dev}/bin/glib-mkenums $out/bin/glib-mkenums --unset PYTHONPATH
    '';
  };
  # make-dconf-override-db.sh needs to execute dbus-launch in the sandbox,
  # it will fail to read /etc/dbus-1/session.conf unless we add this flag
  dbus-launch =
    runCommand "sandbox-dbus-launch"
      {
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper ${dbus}/bin/dbus-launch $out/bin/dbus-launch \
          --add-flags --config-file=${dbus}/share/dbus-1/session.conf
      '';
in

stdenv.mkDerivation (finalAttrs: {
  pname = "ibus";
  version = "1.5.34";

  src = fetchFromGitHub {
    owner = "ibus";
    repo = "ibus";
    tag = finalAttrs.version;
    hash = "sha256-MCxzMnG+g2FC4pZtDOP2c7vSRG5Zk6EfrkGnEyFvBfQ=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals (!libOnly) [
    "installedTests"
  ];

  patches = [
    (replaceVars ./fix-paths.patch {
      # removed line only
      PYTHON = null;
      datarootdir = null;
      localedir = null;
      # patch context
      prefix = null;
      pythonInterpreter = python3Runtime.interpreter;
      pythonSitePackages = python3.sitePackages;
    })
    ./build-without-dbus-launch.patch
  ];

  postPatch = ''
    # Maintainer does not want to create separate tarballs for final release candidate and release versions,
    # so we need to set `ibus_released` to `1` in `configure.ac`. Otherwise, anyone running `ibus version` gets
    # a version with an inaccurate `-rcX` suffix.
    # https://github.com/ibus/ibus/issues/2584
    substituteInPlace configure.ac --replace "m4_define([ibus_released], [0])" "m4_define([ibus_released], [1])"

    patchShebangs --build data/dconf/make-dconf-override-db.sh
    cp ${buildPackages.gtk-doc}/share/gtk-doc/data/gtk-doc.make .
    substituteInPlace bus/services/org.freedesktop.IBus.session.GNOME.service.in --replace "ExecStart=sh" "ExecStart=${runtimeShell}"
    substituteInPlace bus/services/org.freedesktop.IBus.session.generic.service.in --replace "ExecStart=sh" "ExecStart=${runtimeShell}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    gettext
    makeWrapper
    pkg-config
    python3BuildEnv
    dbus-launch
    glib # required to satisfy AM_PATH_GLIB_2_0
    vala
    gobject-introspection
  ]
  ++ lib.optionals (!libOnly) [
    wrapGAppsHook3
  ]
  ++ lib.optionals withWayland [
    wayland-scanner
  ];

  buildInputs = [
    dbus
    systemd
    dconf
    python3.pkgs.pygobject3 # for pygobject overrides
    isocodes
    json-glib
    libx11
    vala # for share/vala/Makefile.vapigen (PKG_CONFIG_VAPIGEN_VAPIGEN)
  ]
  ++ lib.optionals (!libOnly) [
    gtk3
    gtk4
    gdk-pixbuf
    libdbusmenu-gtk3
    libnotify
  ]
  ++ lib.optionals withWayland [
    libxkbcommon
    wayland
    wayland-protocols
    wayland-scanner # For cross, build uses $PKG_CONFIG to look for wayland-scanner
  ];

  propagatedBuildInputs = [
    glib
  ];

  configureFlags = [
    # The `AX_PROG_{CC,CXX}_FOR_BUILD` autoconf macros can pick up unwrapped GCC binaries,
    # so we set `{CC,CXX}_FOR_BUILD` to override that behavior.
    # https://github.com/NixOS/nixpkgs/issues/21751
    "CC_FOR_BUILD=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "CXX_FOR_BUILD=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++"
    "GLIB_COMPILE_RESOURCES=${lib.getDev buildPackages.glib}/bin/glib-compile-resources"
    "PKG_CONFIG_VAPIGEN_VAPIGEN=${lib.getBin buildPackages.vala}/bin/vapigen"
    "--disable-memconf"
    "--disable-gtk2"
    "--with-python=${python3BuildEnv.interpreter}"
    (lib.enableFeature (!libOnly && dconf != null) "dconf")
    (lib.enableFeature (!libOnly && libnotify != null) "libnotify")
    (lib.enableFeature withWayland "wayland")
    (lib.enableFeature enableUI "ui")
    (lib.enableFeature (!libOnly) "gtk3")
    (lib.enableFeature (!libOnly) "gtk4")
    (lib.enableFeature (!libOnly) "xim")
    (lib.enableFeature (!libOnly) "appindicator")
    (lib.enableFeature (!libOnly) "tests")
    (lib.enableFeature (!libOnly) "install-tests")
    (lib.enableFeature (!libOnly) "emoji-dict")
    (lib.enableFeature (!libOnly) "unicode-dict")
  ]
  ++ lib.optionals (!libOnly) [
    "--with-unicode-emoji-dir=${unicode-emoji}/share/unicode/emoji"
    "--with-emoji-annotation-dir=${cldr-annotations}/share/unicode/cldr/common/annotations"
    "--with-ucd-dir=${unicode-character-database}/share/unicode"
  ];

  makeFlags = lib.optionals (!libOnly) [
    "test_execsdir=${placeholder "installedTests"}/libexec/installed-tests/ibus"
    "test_sourcesdir=${placeholder "installedTests"}/share/installed-tests/ibus"
  ];

  doCheck = false; # requires X11 daemon

  postInstall = lib.optionalString (!libOnly) ''
    # It has some hardcoded FHS paths and also we do not use it
    # since we set up the environment in NixOS tests anyway.
    moveToOutput "bin/ibus-desktop-testing-runner" "$installedTests"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = lib.optionalString (!libOnly) ''
    # set necessary environment also for tests
    for f in $installedTests/libexec/installed-tests/ibus/*; do
        wrapGApp $f
    done
  '';

  depsBuildBuild = [
    pkg-config
  ];

  enableParallelBuilding = true;
  preAutoreconf = "touch ChangeLog";
  versionCheckProgram = "${placeholder "out"}/bin/ibus";
  versionCheckProgramArg = "version";

  passthru = {
    tests = lib.optionalAttrs (!libOnly) {
      installed-tests = nixosTests.installed-tests.ibus;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Intelligent Input Bus, input method framework";
    homepage = "https://github.com/ibus/ibus";
    changelog = "https://github.com/ibus/ibus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ibus";
  };
})
