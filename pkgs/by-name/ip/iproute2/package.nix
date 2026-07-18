{
  lib,
  stdenv,
  fetchurl,
  bison,
  buildPackages,
  db,
  elfutils,
  flex,
  gitUpdater,
  iptables,
  libbpf,
  libmnl,
  pkg-config,
  pkgsStatic,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "iproute2";
  version = "7.1.0";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/net/iproute2/iproute2-${version}.tar.xz";
    hash = "sha256-/Z+huVgJQXFXyoPdcpV+MmG9vOiWNTy5NvgK8LM6S1w=";
  };

  outputs = [
    "out"
    "dev"
    "scripts"
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC := gcc" "CC ?= $CC"
  '';

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ];

  buildInputs = [
    db
    iptables
    libmnl
    python3
  ]
  # needed to uploaded bpf programs
  ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
    elfutils
    libbpf
  ];

  configureFlags = [
    "--color"
    "auto"
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "SBINDIR=$(out)/sbin"
    "DOCDIR=$(TMPDIR)/share/doc/${pname}" # Don't install docs
    "HDRDIR=$(dev)/include/iproute2"
  ]
  ++ lib.optionals stdenv.hostPlatform.isStatic [
    "SHARED_LIBS=n"
    # all build .so plugins:
    "TC_CONFIG_NO_XT=y"
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "HOSTCC=$(CC_FOR_BUILD)"
  ];

  buildFlags = [
    "CONFDIR=/etc/iproute2"
  ];

  postInstall = ''
    moveToOutput sbin/routel "$scripts"
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ]; # netem requires $HOSTCC
  enableParallelBuilding = true;

  installFlags = [
    "CONFDIR=$(out)/etc/iproute2"
  ];

  # needed for nixos-anywhere
  passthru.tests.static = pkgsStatic.iproute2;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    # No nicer place to find latest release.
    url = "https://git.kernel.org/pub/scm/network/iproute2/iproute2.git";
  };

  meta = {
    description = "Collection of utilities for controlling TCP/IP networking and traffic control in Linux";
    homepage = "https://wiki.linuxfoundation.org/networking/iproute2";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      fpletz
    ];

    platforms = lib.platforms.linux;
  };
}
