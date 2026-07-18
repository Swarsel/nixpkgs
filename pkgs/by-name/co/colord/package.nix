{
  lib,
  stdenv,
  fetchurl,
  argyllcms,
  bash-completion,
  dbus,
  docbook_xml_dtd_412,
  docbook_xsl,
  docbook_xsl_ns,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  gusb,
  lcms2,
  libgudev,
  libxslt,
  meson,
  mesonEmulatorHook,
  ninja,
  nixosTests,
  pkg-config,
  polkit,
  sane-backends,
  shared-mime-info,
  sqlite,
  systemd,
  udev,
  udevCheckHook,
  vala,
  wrapGAppsNoGuiHook,
  enableDaemon ? true,
  enableSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "colord";
  version = "1.4.8";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/colord/releases/colord-${finalAttrs.version}.tar.xz";
    hash = "sha256-IVAL1ol1MSp/DzzmAZ2fdfQqrKp1ynEV7HILVEVAaJY=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "man"
    "installedTests"
  ];

  patches = [
    # Put installed tests into its own output
    ./installed-tests-path.patch
  ];

  postPatch = ''
    for file in data/tests/meson.build lib/colord/cd-test-shared.c lib/colord/meson.build; do
        substituteInPlace $file --subst-var-by installed_tests_dir "$installedTests"
    done
  '';

  nativeBuildInputs = [
    docbook_xml_dtd_412
    docbook_xsl
    docbook_xsl_ns
    gettext
    gobject-introspection
    gtk-doc
    libxslt
    meson
    ninja
    pkg-config
    shared-mime-info
    vala
    wrapGAppsNoGuiHook
    udevCheckHook
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    argyllcms
    bash-completion
    dbus
    glib
    gusb
    lcms2
    libgudev
    sane-backends
    sqlite
    udev
  ]
  ++ lib.optionals enableSystemd [
    systemd
  ]
  ++ lib.optionals enableDaemon [
    polkit
  ];

  mesonFlags = [
    "--localstatedir=/var"
    "-Dinstalled_tests=true"
    "-Dlibcolordcompat=true"
    "-Dsane=true"
    "-Dvapi=true"
    "-Ddaemon=${lib.boolToString enableDaemon}"
    "-Ddaemon_user=colord"
    (lib.mesonBool "systemd" enableSystemd)

    # The presence of the "udev" pkg-config module (as opposed to "libudev")
    # indicates whether rules are supported.
    (lib.mesonBool "udev_rules" (lib.elem "udev" udev.meta.pkgConfigModules))
  ];

  env = {
    PKG_CONFIG_BASH_COMPLETION_COMPLETIONSDIR = "${placeholder "out"}/share/bash-completion/completions";
    PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
    PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";
    PKG_CONFIG_SYSTEMD_SYSUSERSDIR = "${placeholder "out"}/lib/sysusers.d";
    PKG_CONFIG_SYSTEMD_TMPFILESDIR = "${placeholder "out"}/lib/tmpfiles.d";
    PKG_CONFIG_UDEV_UDEVDIR = "${placeholder "out"}/lib/udev";
  };

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  doInstallCheck = true;

  passthru = {
    tests = {
      installedTests = nixosTests.installed-tests.colord;
    };
  };

  meta = {
    description = "System service to manage, install and generate color profiles to accurately color manage input and output devices";
    homepage = "https://www.freedesktop.org/software/colord/";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
