{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  gusb,
  libfprint,
  libxslt,
  meson,
  ninja,
  nss,
  pam,
  perl,
  pkg-config,
  polkit,
  python3,
  systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fprintd";
  version = "1.94.5";

  src = fetchFromGitLab {
    owner = "libfprint";
    repo = "fprintd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aGIz50S0zfE3rV6QJp8iQz3uUVn8WAL68KU70j8GyOU=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  patches = [
    # Skip flaky test "test_removal_during_enroll"
    # https://gitlab.freedesktop.org/libfprint/fprintd/-/issues/129
    ./skip-test-test_removal_during_enroll.patch
  ];

  postPatch = ''
    patchShebangs \
      po/check-translations.sh \
      tests/unittest_inspector.py

    # Stop tests from failing due to unhandled GTasks uncovered by GLib 2.76 bump.
    # https://gitlab.freedesktop.org/libfprint/fprintd/-/issues/151
    substituteInPlace tests/fprintd.py \
      --replace "env['G_DEBUG'] = 'fatal-criticals'" ""
    substituteInPlace tests/meson.build \
      --replace "'G_DEBUG=fatal-criticals'," ""
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    perl # for pod2man
    gettext
    gtk-doc
    python3
    libxslt
    dbus
    docbook-xsl-nons
    docbook_xml_dtd_412
  ];

  buildInputs = [
    glib
    polkit
    nss
    pam
    systemdLibs
    libfprint
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dpam_modules_dir=${placeholder "out"}/lib/security"
    "-Dsysconfdir=${placeholder "out"}/etc"
    "-Ddbus_service_dir=${placeholder "out"}/share/dbus-1/system-services"
    "-Dsystemd_system_unit_dir=${placeholder "out"}/lib/systemd/system"
  ];

  env = {
    # FIXME: Ugly hack for tests to find libpam_wrapper.so
    LIBRARY_PATH = lib.makeLibraryPath [ python3.pkgs.pypamtest ];
    PKG_CONFIG_DBUS_1_DATADIR = "${placeholder "out"}/share";
    PKG_CONFIG_DBUS_1_INTERFACES_DIR = "${placeholder "out"}/share/dbus-1/interfaces";
    PKG_CONFIG_POLKIT_GOBJECT_1_POLICYDIR = "${placeholder "out"}/share/polkit-1/actions";
  };

  nativeCheckInputs = with python3.pkgs; [
    gobject-introspection # for setup hook
    python-dbusmock
    dbus-python
    pygobject3
    pycairo
    pypamtest
    gusb # Required by libfprint’s typelib
  ];

  mesonCheckFlags = [
    # PAM related checks are timing out
    "--no-suite"
    "fprintd:TestPamFprintd"
  ];

  meta = {
    description = "D-Bus daemon that offers libfprint functionality over the D-Bus interprocess communication bus";
    homepage = "https://fprint.freedesktop.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
