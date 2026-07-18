{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  buildPackages,
  gettext,
  icu,
  inih,
  liburcu,
  libuuid,
  nixosTests,
  pkg-config,
  python3,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfsprogs";
  version = "7.0.1";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/fs/xfs/xfsprogs/xfsprogs-${finalAttrs.version}.tar.xz";
    hash = "sha256-SoyoOnrLjNksmX1jtprmTxcAVrNmopJKdT5H1LtLiwY=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "doc"
    "man"
  ];

  postPatch = ''
    substituteInPlace {./scrub/xfs_scrub_all.py.in,./mkfs/xfs_protofile.py.in}\
      --replace-fail '#!/usr/bin/python3' '#!/usr/bin/env python3'
  '';

  nativeBuildInputs = [
    autoreconfHook
    gettext
    pkg-config
    libuuid # codegen tool uses libuuid
    liburcu # required by crc32selftest
  ];

  buildInputs = [
    readline
    icu
    inih
    liburcu
    (python3.withPackages (ps: [ ps.dbus-python ]))
  ];

  propagatedBuildInputs = [ libuuid ]; # Dev headers include <uuid/uuid.h>

  configureFlags = [
    "--disable-lib64"
    "--with-systemd-unit-dir=${placeholder "out"}/lib/systemd/system"
  ];

  # @sbindir@ is replaced with /run/current-system/sw/bin to fix dependency cycles
  # and '@pkg_state_dir@' should not point to the nix store, but we cannot use the configure parameter
  # because then it will try to install to /var
  preConfigure = ''
    for file in scrub/*.in; do
      substituteInPlace "$file" \
        --replace-quiet '@sbindir@' '/run/current-system/sw/bin' \
        --replace-quiet '@stampfile@' '@pkg_state_dir@/xfs_scrub_all_media.stamp' \
        --replace-quiet '@pkg_state_dir@' '/var/lib/xfsprogs'
    done
    patchShebangs ./install-sh
  '';

  # FIXME: forbidden rpath
  postInstall = ''
    find . -type d -name .libs | xargs rm -rf
  '';

  # The default --force would replace xfsprogs' custom install-sh.
  autoreconfFlags = [
    "--install"
    "--verbose"
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  # Install fails as:
  #   make[1]: *** No rule to make target '\', needed by 'kmem.lo'.  Stop.
  enableParallelInstalling = false;
  installFlags = [ "install-dev" ];

  passthru.tests = {
    inherit (nixosTests.installer) lvm;
  };

  meta = {
    description = "SGI XFS utilities";
    homepage = "https://xfs.wiki.kernel.org";

    license = with lib.licenses; [
      gpl2Only
      lgpl21
      gpl3Plus
    ]; # see https://git.kernel.org/pub/scm/fs/xfs/xfsprogs-dev.git/tree/debian/copyright

    maintainers = with lib.maintainers; [
      ajs124
    ];

    platforms = lib.platforms.linux;
  };
})
