{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  libmnl,
  libnetfilter_conntrack,
  libnetfilter_cthelper,
  libnetfilter_cttimeout,
  libnetfilter_queue,
  libnfnetlink,
  libtirpc,
  pkg-config,
  systemdLibs,
  systemdSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conntrack-tools";
  version = "1.4.8";

  src = fetchurl {
    url = "https://www.netfilter.org/projects/conntrack-tools/files/conntrack-tools-${finalAttrs.version}.tar.xz";
    hash = "sha256-BnZ39MX2VkgZ547TqdSomAk16pJz86uyKkIOowq13tY=";
  };

  nativeBuildInputs = [
    flex
    bison
    pkg-config
  ];

  buildInputs = [
    libmnl
    libnfnetlink
    libnetfilter_conntrack
    libnetfilter_queue
    libnetfilter_cttimeout
    libnetfilter_cthelper
    libtirpc
  ]
  ++ lib.optionals systemdSupport [
    systemdLibs
  ];

  configureFlags = [
    (lib.enableFeature systemdSupport "systemd")
  ];

  meta = {
    description = "Connection tracking userspace tools";
    homepage = "https://conntrack-tools.netfilter.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "netfilter" finalAttrs.version;
  };
})
