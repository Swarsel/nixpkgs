{
  lib,
  stdenv,
  fetchurl,
  # passthru.tests
  bind,
  buildPackages,
  chrony,
  go,
  htop,
  libcap,
  libgcrypt,
  libvirt,
  ntp,
  pkgsBuildHost,
  qemu,
  runtimeShell,
  squid,
  testers,
  tor,
  uwsgi,
  isStatic ? stdenv.hostPlatform.isStatic,
  pam ? null,
  usePam ? !isStatic,
  withGo ? lib.meta.availableOn stdenv.buildPlatform go && stdenv.hostPlatform.go.GOARCH != null,
}:

assert usePam -> pam != null;

stdenv.mkDerivation rec {
  pname = "libcap";
  version = "2.78";

  src = fetchurl {
    url = "mirror://kernel/linux/libs/security/linux-privs/libcap2/${pname}-${version}.tar.xz";
    hash = "sha256-DWIeVi/ZMsz2e5Zg+wGORopoPXuCdUHfJ4EyKMmWuxE=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
    "doc"
  ]
  ++ lib.optional usePam "pam";

  postPatch = ''
    patchShebangs ./progs/mkcapshdoc.sh

    # use full path to bash
    substituteInPlace progs/capsh.c --replace "/bin/bash" "${runtimeShell}"

    # set prefixes
    substituteInPlace Make.Rules \
      --replace 'prefix=/usr' "prefix=$lib" \
      --replace 'exec_prefix=' "exec_prefix=$out" \
      --replace 'lib_prefix=$(exec_prefix)' "lib_prefix=$lib" \
      --replace 'inc_prefix=$(prefix)' "inc_prefix=$dev" \
      --replace 'man_prefix=$(prefix)' "man_prefix=$doc"
  '';

  strictDeps = true;

  nativeBuildInputs = lib.optionals withGo [
    go
  ];

  buildInputs = lib.optional usePam pam;

  makeFlags = [
    "lib=lib"
    "PAM_CAP=${lib.boolToYesNo usePam}"
    "BUILD_CC=$(CC_FOR_BUILD)"
    "CC:=$(CC)"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ]
  ++ lib.optionals withGo [
    "GOLANG=yes"
    "GOCACHE=\${TMPDIR}/go-cache"
    "GOFLAGS=-trimpath"
    "GOARCH=${pkgsBuildHost.go.GOARCH}"
    "GOOS=${pkgsBuildHost.go.GOOS}"
  ]
  ++ lib.optionals isStatic [
    "SHARED=no"
    "LIBCSTATIC=yes"
  ];

  postInstall = ''
    ${lib.optionalString (!isStatic) ''rm "$lib"/lib/*.a''}
    mkdir -p "$doc/share/doc/${pname}-${version}"
    cp License "$doc/share/doc/${pname}-${version}/"
  ''
  + lib.optionalString usePam ''
    mkdir -p "$pam/lib/security"
    mv "$lib"/lib/security "$pam/lib"
  '';

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  disallowedReferences = lib.optionals withGo [
    pkgsBuildHost.go
  ];

  installFlags = [ "RAISE_SETFCAP=no" ];

  passthru.tests = {
    inherit
      bind
      chrony
      htop
      libgcrypt
      libvirt
      ntp
      qemu
      squid
      tor
      uwsgi
      ;

    pkg-config = testers.hasPkgConfigModules {
      package = libcap;
    };
  };

  meta = {
    description = "Library for working with POSIX capabilities";
    homepage = "https://sites.google.com/site/fullycapable";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "libcap_project" version;

    pkgConfigModules = [
      "libcap"
      "libpsx"
    ];
  };
}
