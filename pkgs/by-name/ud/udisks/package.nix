{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  autoreconfHook,
  bash,
  btrfs-progs,
  coreutils,
  docbook_xml_dtd_412,
  docbook_xml_dtd_43,
  docbook_xsl,
  dosfstools,
  e2fsprogs,
  exfat,
  expat,
  f2fs-tools,
  glib,
  gnused,
  gobject-introspection,
  gtk-doc,
  libatasmart,
  libblockdev,
  libconfig,
  libgudev,
  libiscsi,
  libxslt,
  mdadm,
  nilfs-utils,
  nixosTests,
  ntfs3g,
  parted,
  pkg-config,
  polkit,
  replaceVars,
  systemd,
  udevCheckHook,
  util-linux,
  which,
  xfsprogs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "udisks";
  version = "2.11.1";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "udisks";
    tag = "udisks-${finalAttrs.version}";
    hash = "sha256-FZr5AhAxvMbaonYIClHgxsoHaGR2nIClK65IEaYxMeA=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ]
  ++ lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "devdoc";

  patches = [
    (replaceVars ./fix-paths.patch {
      false = "${coreutils}/bin/false";
      mdadm = "${mdadm}/bin/mdadm";
      sed = "${gnused}/bin/sed";
      sh = "${bash}/bin/sh";
      sleep = "${coreutils}/bin/sleep";
      true = "${coreutils}/bin/true";
    })
    (replaceVars ./force-path.patch {
      path = lib.makeBinPath [
        btrfs-progs
        coreutils
        dosfstools
        e2fsprogs
        exfat
        f2fs-tools
        nilfs-utils
        xfsprogs
        ntfs3g
        parted
        util-linux
      ];
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isMusl ''
    substituteInPlace udisks/udisksclient.c \
      --replace 'defined( __GNUC_PREREQ)' 1 \
      --replace '__GNUC_PREREQ(4,6)' 1
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    which
    gobject-introspection
    pkg-config
    gtk-doc
    libxslt
    docbook_xml_dtd_412
    docbook_xml_dtd_43
    docbook_xsl
    udevCheckHook
  ];

  buildInputs = [
    expat
    libgudev
    libblockdev
    acl
    systemd
    glib
    libatasmart
    polkit
    util-linux
    libiscsi
    libconfig
  ];

  configureFlags = [
    (lib.enableFeature (stdenv.buildPlatform == stdenv.hostPlatform) "gtk-doc")
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-udevdir=$(out)/lib/udev"
    "--with-tmpfilesdir=no"
    "--enable-all-modules"
    "--enable-btrfs"
    "--enable-lvm2"
    "--enable-smart"
  ];

  makeFlags = [
    "INTROSPECTION_GIRDIR=$(dev)/share/gir-1.0"
    "INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0"
  ];

  preConfigure = "NOCONFIGURE=1 ./autogen.sh";
  doCheck = true;
  doInstallCheck = true;
  # pkg-config had to be in both to find gtk-doc and gobject-introspection
  depsBuildBuild = [ pkg-config ];
  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
  ];

  passthru = {
    inherit libblockdev;
    tests.vm = nixosTests.udisks2;
  };

  meta = {
    description = "Daemon, tools and libraries to access and manipulate disks, storage devices and technologies";
    homepage = "https://www.freedesktop.org/wiki/Software/udisks/";

    license = with lib.licenses; [
      lgpl2Plus
      gpl2Plus
    ]; # lgpl2Plus for the library, gpl2Plus for the tools & daemon

    maintainers = with lib.maintainers; [ johnazoidberg ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
