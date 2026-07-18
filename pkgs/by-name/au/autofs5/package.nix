{
  lib,
  stdenv,
  fetchurl,
  bison,
  cyrus_sasl,
  e2fsprogs,
  fetchpatch,
  flex,
  kmod,
  libkrb5,
  libnsl,
  libtirpc,
  libxml2,
  linuxHeaders,
  mount,
  nfs-utils,
  openldap,
  openssl,
  pkgconf,
  rpcsvc-proto,
  sssd,
  umount,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "autofs";
  version = "5.1.9";

  src = fetchurl {
    url = "mirror://kernel/linux/daemons/autofs/v5/autofs-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-h+avagN5S5Ri6lGXgeUOfSO198ks1Z4RQshdJJOzwks=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-BomhNw+lMHcgs5gQlzapZ6p/Ji3gJUVkrLpZssBmwbg=";
      url = "mirror://kernel/linux/daemons/autofs/v5/patches-5.2.0/autofs-5.1.9-update-configure.patch";
    })
    (fetchpatch {
      hash = "sha256-W757LU9r9kuzLeThif2a1olRtxNrJy5suemLS7yfbIU=";
      url = "mirror://kernel/linux/daemons/autofs/v5/patches-5.2.0/autofs-5.1.9-fix-ldap_parse_page_control-check.patch";
    })
    (fetchpatch {
      hash = "sha256-YjTdJ50iNhJ2UjFdrKYEFNt04z0PfmElbFa4GuSskLA=";
      url = "mirror://kernel/linux/daemons/autofs/v5/patches-5.2.0/autofs-5.1.9-fix-crash-in-make_options_string.patch";
    })
    (fetchpatch {
      hash = "sha256-erLlqZtVmYqUOsk3S7S50yA0VB8Gzibsv+X50+gcA58=";
      url = "mirror://kernel/linux/daemons/autofs/v5/patches-5.2.0/autofs-5.1.9-Fix-incompatible-function-pointer-types-in-cyrus-sasl-module.patch";
    })
  ];

  nativeBuildInputs = [
    flex
    bison
    pkgconf
    libnsl.dev
  ];

  buildInputs = [
    linuxHeaders
    libtirpc
    libxml2
    libkrb5
    kmod
    openldap
    sssd
    openssl
    cyrus_sasl
    rpcsvc-proto
    libnsl
  ];

  preConfigure = ''
    configureFlags="--enable-force-shutdown --enable-ignore-busy --with-path=$PATH --with-libtirpc"
    export sssldir="${sssd}/lib/sssd/modules"
    export HAVE_SSS_AUTOFS=1

    export MOUNT=${mount}/bin/mount
    export MOUNT_NFS=${nfs-utils}/bin/mount.nfs
    export UMOUNT=${umount}/bin/umount
    export MODPROBE=${kmod}/bin/modprobe
    export E2FSCK=${e2fsprogs}/bin/fsck.ext2
    export E3FSCK=${e2fsprogs}/bin/fsck.ext3
    export E4FSCK=${e2fsprogs}/bin/fsck.ext4

    unset STRIP # Makefile.rules defines a usable STRIP only without the env var.
  '';

  installPhase = ''
    make install SUBDIRS="lib daemon modules man" # all but samples
    #make install SUBDIRS="samples" # impure!
  '';

  meta = {
    description = "Kernel-based automounter";
    homepage = "https://www.kernel.org/pub/linux/daemons/autofs/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "automount";
    executables = [ "automount" ];
  };
})
