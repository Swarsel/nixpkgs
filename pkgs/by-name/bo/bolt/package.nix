{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoc,
  dbus,
  docbook-xsl-nons,
  docbook_xml_dtd_45,
  fetchpatch,
  glib,
  gobject-introspection,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  polkit,
  python3,
  systemd,
  udevCheckHook,
  umockdev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bolt";
  version = "0.9.8";

  src = fetchFromGitLab {
    owner = "bolt";
    repo = "bolt";
    tag = finalAttrs.version;
    hash = "sha256-sDPipSIT2MJMdsOjOQSB+uOe6KXzVnyAqcQxPPr2NsU=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    # Test does not work on ZFS with atime disabled.
    # Upstream issue: https://gitlab.freedesktop.org/bolt/bolt/-/issues/167
    (fetchpatch {
      hash = "sha256-6w7ll65W/CydrWAVi/qgzhrQeDv1PWWShulLxoglF+I=";
      revert = true;
      url = "https://gitlab.freedesktop.org/bolt/bolt/-/commit/c2f1d5c40ad71b20507e02faa11037b395fac2f8.diff";
    })
  ];

  postPatch = ''
    patchShebangs scripts tests
  '';

  nativeBuildInputs = [
    asciidoc
    docbook_xml_dtd_45
    docbook-xsl-nons
    libxml2
    libxslt
    meson
    ninja
    pkg-config
    glib
    udevCheckHook
  ];

  buildInputs = [
    polkit
    systemd
  ];

  mesonFlags = [
    "-Dlocalstatedir=/var"
  ];

  env = {
    PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
    PKG_CONFIG_UDEV_UDEVDIR = "${placeholder "out"}/lib/udev";
  };

  nativeCheckInputs = [
    dbus
    gobject-introspection
    umockdev
    (python3.pythonOnBuildForHost.withPackages (p: [
      p.pygobject3
      p.dbus-python
      p.python-dbusmock
    ]))
  ];

  preCheck = ''
    export LD_LIBRARY_PATH=${umockdev.out}/lib/
  '';

  doInstallCheck = true;

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Thunderbolt 3 device management daemon";
    homepage = "https://gitlab.freedesktop.org/bolt/bolt";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "boltctl";
  };
})
