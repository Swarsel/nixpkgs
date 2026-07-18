{
  lib,
  stdenv,
  fetchFromGitHub,
  dpdk,
  gtk2,
  libbsd,
  libpcap,
  lua5_3,
  meson,
  ninja,
  nix-update-script,
  numactl,
  pkg-config,
  util-linux,
  which,
  withGtk ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pktgen";
  version = "26.03.0";

  src = fetchFromGitHub {
    owner = "pktgen";
    repo = "Pktgen-DPDK";
    tag = "pktgen-${finalAttrs.version}";
    hash = "sha256-GNBo0WsHevoge97gUgDdNygCHSA5fQ/73ibsTvDvVYI=";
  };

  postPatch = ''
    substituteInPlace lib/common/lscpu.h --replace /usr/bin/lscpu ${lib.getExe' util-linux "lscpu"}
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    dpdk
    libbsd
    libpcap
    lua5_3
    numactl
    which
  ]
  ++ lib.optionals withGtk [
    gtk2
  ];

  env = {
    GUI = lib.optionalString withGtk "true";

    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=sign-compare"
    ];

    # requires symbols from this file
    NIX_LDFLAGS = "-lrte_net_bond";
    RTE_SDK = dpdk;
  };

  postInstall = ''
    # meson installs unneeded files with conflicting generic names, such as
    # include/cli.h and lib/liblua.so.
    rm -rf $out/include $out/lib
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Traffic generator powered by DPDK";
    homepage = "http://dpdk.org/";
    license = lib.licenses.bsdOriginal;

    maintainers = with lib.maintainers; [
      abuibrahim
      stepbrobd
    ];

    platforms = lib.platforms.linux;
  };
})
