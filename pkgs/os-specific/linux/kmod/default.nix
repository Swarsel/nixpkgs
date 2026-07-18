{
  lib,
  stdenv,
  autoconf,
  automake,
  docbook_xml_dtd_42,
  docbook_xml_dtd_43,
  docbook_xsl,
  elf-header,
  fetchpatch,
  fetchzip,
  gitUpdater,
  gtk-doc,
  libtool,
  libxslt,
  pkg-config,
  xz,
  zstd,
  withDevdoc ? stdenv.hostPlatform == stdenv.buildPlatform,
  withStatic ? stdenv.hostPlatform.isStatic,
}:

let
  systems = [
    "/run/booted-system/kernel-modules"
    "/run/current-system/kernel-modules"
    ""
  ];
  modulesDirs = lib.concatMapStringsSep ":" (x: "${x}/lib/modules") systems;

in
stdenv.mkDerivation rec {
  pname = "kmod";
  version = "31";

  # autogen.sh is missing from the release tarball,
  # and we need to run it to regenerate gtk_doc.make,
  # because the version in the release tarball is broken.
  # Possibly this will be fixed in kmod 30?
  # https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git/commit/.gitignore?id=61a93a043aa52ad62a11ba940d4ba93cb3254e78
  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git/snapshot/kmod-${version}.tar.gz";
    hash = "sha256-FNR015/AoYBbi7Eb1M2TXH3yxUuddKICCu+ot10CdeQ=";
  };

  outputs = [
    "out"
    "man"
    "dev"
    "lib"
  ]
  ++ lib.optional withDevdoc "devdoc";

  patches = [
    # Accept multiple default kernel module dirs at build-time, instead
    # of hardcoding a single /lib/modules, and adjust module search logic
    # accordingly (to account for multiple default directories)
    ./module-dir.patch

    # Use portable implementation for basename API
    #
    # musl has removed the non-prototype declaration of basename from string.h
    # which now results in build errors with clang-17+ compiler
    #
    # Implement GNU basename behavior using strchr which is portable across libcs
    #
    # Fixes "call to undeclared function 'basename'" error on clang+musl
    (fetchpatch {
      hash = "sha256-CYG615elMWces6QGQRg2H/NL7W4XsG9Zvz5H+xsdFFo=";
      name = "musl.patch";
      url = "https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git/patch/?id=11eb9bc67c319900ab00523997323a97d2d08ad2";
    })
  ]
  # Force configure.ac to accept --enable-static (no other changes necessary)
  ++ lib.optional withStatic ./enable-static.patch;

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    docbook_xsl
    libtool
    libxslt
    pkg-config

    docbook_xml_dtd_42 # for the man pages
  ]
  ++ lib.optionals withDevdoc [
    docbook_xml_dtd_43
    gtk-doc
  ];

  buildInputs = [
    xz
    zstd
  ]
  # gtk-doc is looked for with pkg-config
  ++ lib.optionals withDevdoc [ gtk-doc ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-xz"
    "--with-zstd"
    "--with-modulesdirs=${modulesDirs}"
    (lib.enableFeature withDevdoc "gtk-doc")
  ]
  ++ lib.optional withStatic "--enable-static";

  preConfigure = ''
    ./autogen.sh
  '';

  postInstall = ''
    for prog in rmmod insmod lsmod modinfo modprobe depmod; do
      ln -sv $out/bin/kmod $out/bin/$prog
    done

    # Backwards compatibility
    ln -s bin $out/sbin
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    # No nicer place to find latest release.
    url = "https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git";
  };

  meta = {
    description = "Tools for loading and managing Linux kernel modules";

    longDescription = ''
      kmod is a set of tools to handle common tasks with Linux kernel modules
      like insert, remove, list, check properties, resolve dependencies and
      aliases. These tools are designed on top of libkmod, a library that is
      shipped with kmod.
    '';

    homepage = "https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git/";
    changelog = "https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git/plain/NEWS?h=v${version}";

    license = with lib.licenses; [
      lgpl21Plus
      gpl2Plus
    ]; # GPLv2+ for tools

    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    downloadPage = "https://www.kernel.org/pub/linux/utils/kernel/kmod/";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "kernel" version;
    teams = [ lib.teams.security-review ];
  };
}
