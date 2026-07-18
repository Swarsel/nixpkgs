{
  lib,
  stdenv,
  fetchurl,
  gmp,
  iproute2,
  net-tools,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gvpe";
  version = "3.1";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/gvpe/gvpe-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-8evVctclu5QOCAdxocEIZ8NQnc2DFvYRSBRQPcux6LM=";
  };

  postPatch = ''
    sed -e 's@"/sbin/ifconfig.*"@"${iproute2}/sbin/ip link set dev $IFNAME address $MAC mtu $MTU"@' -i src/device-linux.C
    sed -e 's@/sbin/ifconfig@${net-tools}/sbin/ifconfig@g' -i src/device-*.C
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    gmp
    zlib
  ];

  configureFlags = [
    "--enable-tcp"
    "--enable-http-proxy"
    "--enable-dns"
  ];

  meta = {
    description = "Protected multinode virtual network";
    homepage = "http://software.schmorp.de/pkg/gvpe.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = with lib.platforms; linux ++ freebsd;
  };
})
