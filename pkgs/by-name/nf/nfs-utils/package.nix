{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  coreutils,
  cyrus_sasl,
  fetchpatch,
  keyutils,
  kmod,
  libcap,
  libevent,
  libkrb5,
  libnl,
  libtirpc,
  libuuid,
  libxml2,
  lvm2,
  nixosTests,
  openldap,
  pkg-config,
  python3,
  readline,
  rpcsvc-proto,
  sqlite,
  systemd,
  udevCheckHook,
  util-linux,
  enableLdap ? true,
  enablePython ? true,
}:

let
  statdPath = lib.makeBinPath [
    systemd
    util-linux
    coreutils
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "nfs-utils";
  version = "2.9.1";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/nfs-utils/${finalAttrs.version}/nfs-utils-${finalAttrs.version}.tar.xz";
    hash = "sha256-MChGNDv1Cfj4hMI729D+hTt/fLtlcgYKkIInnROyGiw=";
  };

  # libnfsidmap is built together with nfs-utils from the same source,
  # put it in the "lib" output, and the headers in "dev"
  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  patches = lib.optionals stdenv.hostPlatform.isMusl [
    # http://openwall.com/lists/musl/2015/08/18/10
    (fetchpatch {
      sha256 = "1fqws9dz8n1d9a418c54r11y3w330qgy2652dpwcy96cm44sqyhf";
      url = "https://raw.githubusercontent.com/alpinelinux/aports/cb880042d48d77af412d4688f24b8310ae44f55f/main/nfs-utils/musl-getservbyport.patch";
    })
    (fetchpatch {
      hash = "sha256-dZEafrXDZH/IPo1u7B65u01nwFMfcqSMnVyHAapexa8=";
      url = "https://github.com/void-linux/void-packages/raw/31f0d5fef2f74999212bcfa6f982969973432750/srcpkgs/nfs-utils/patches/musl-includes.patch";
    })
    (fetchpatch {
      hash = "sha256-wcQ2IRmlBP61qZVlXk6osi4UH8ETtjllVogPEaZNK9o=";
      url = "https://github.com/void-linux/void-packages/raw/31f0d5fef2f74999212bcfa6f982969973432750/srcpkgs/nfs-utils/patches/musl-fix_long_unsigned_int.patch";
    })
  ];

  postPatch = ''
    patchShebangs tests
    sed -i "s,/usr/sbin,$out/bin,g" utils/statd/statd.c
    sed -i "s,^PATH=.*,PATH=$out/bin:${statdPath}," utils/statd/start-statd

    substituteInPlace systemd/nfs-utils.service \
      --replace "/bin/true" "${coreutils}/bin/true"

    substituteInPlace tools/nfsrahead/Makefile.in systemd/Makefile.in \
      --replace "/usr/lib/udev/rules.d/" "$out/lib/udev/rules.d/"

    substituteInPlace utils/mount/Makefile.in \
      --replace-fail "chmod 4711" "chmod 0711"

    sed '1i#include <stdint.h>' -i support/nsm/rpc.c
  '';

  nativeBuildInputs = [
    pkg-config
    buildPackages.stdenv.cc
    rpcsvc-proto
    udevCheckHook
  ];

  buildInputs = [
    libtirpc
    libcap
    libevent
    libnl
    sqlite
    lvm2
    libuuid
    keyutils
    libkrb5
    libxml2
    readline
  ]
  ++ lib.optional enablePython python3
  ++ lib.optionals enableLdap [
    openldap
    cyrus_sasl
  ];

  configureFlags = [
    "--with-start-statd=${placeholder "out"}/bin/start-statd"
    "--enable-gss"
    "--enable-svcgss"
    "--with-statedir=/var/lib/nfs"
    "--with-krb5=${lib.getLib libkrb5}"
    "--with-systemd=${placeholder "out"}/etc/systemd/system"
    "--enable-libmount-mount"
    "--with-pluginpath=${placeholder "lib"}/lib/libnfsidmap" # this installs libnfsidmap
    "--with-rpcgen=${buildPackages.rpcsvc-proto}/bin/rpcgen"
    "--with-modprobedir=${placeholder "out"}/etc/modprobe.d"
  ]
  ++ lib.optional enableLdap "--enable-ldap";

  makeFlags = [
    "sbindir=$(out)/bin"
    "generator_dir=$(out)/etc/systemd/system-generators"
  ];

  preConfigure = ''
    substituteInPlace configure \
      --replace '$dir/include/gssapi' ${lib.getDev libkrb5}/include/gssapi \
      --replace '$dir/bin/krb5-config' ${lib.getDev libkrb5}/bin/krb5-config
  '';

  # One test fails on mips.
  # doCheck = !stdenv.hostPlatform.isMips;
  # https://bugzilla.kernel.org/show_bug.cgi?id=203793
  doCheck = false;

  postInstall = ''
    # Not used on NixOS
    sed -i \
      -e "s,/sbin/modprobe,${kmod}/bin/modprobe,g" \
      -e "s,/usr/sbin,$out/bin,g" \
      $out/etc/systemd/system/*
  ''
  + lib.optionalString (!enablePython) ''
    # Remove all scripts that require python (currently mountstats and nfsiostat)
    grep -l /usr/bin/python $out/bin/* | xargs -I {} rm -v {}
  '';

  doInstallCheck = true;
  disallowedReferences = [ (lib.getDev libkrb5) ];
  enableParallelBuilding = true;

  installFlags = [
    "statedir=$(TMPDIR)"
    "statdpath=$(TMPDIR)"
  ];

  stripDebugList = [
    "lib"
    "libexec"
    "bin"
    "etc/systemd/system-generators"
  ];

  passthru.tests = {
    nfs3-simple = nixosTests.nfs3.simple;
    nfs4-kerberos = nixosTests.nfs4.kerberos;
    nfs4-simple = nixosTests.nfs4.simple;
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Linux user-space NFS utilities";

    longDescription = ''
      This package contains various Linux user-space Network File
      System (NFS) utilities, including RPC `mount' and `nfs'
      daemons.
    '';

    homepage = "https://linux-nfs.org/";
    changelog = "https://www.kernel.org/pub/linux/utils/nfs-utils/${finalAttrs.version}/${finalAttrs.version}-Changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.linux;
  };
})
