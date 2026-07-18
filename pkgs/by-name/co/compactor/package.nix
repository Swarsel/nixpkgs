{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  autoreconfHook,
  boost186,
  catch2,
  cbor-diag,
  cddl,
  diffutils,
  fetchpatch,
  file,
  libctemplate,
  libmaxminddb,
  libpcap,
  libtins,
  mktemp,
  netcat,
  openssl,
  pkg-config,
  protobuf_21,
  tcpdump,
  wireshark-cli,
  xz,
  zlib,
}:
let
  protobuf = protobuf_21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "compactor";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "dns-stats";
    repo = "compactor";
    tag = finalAttrs.version;
    hash = "sha256-5Z14suhO5ghhmZsSj4DsSoKm+ct2gQFO6qxhjmx4Xm4=";
    fetchSubmodules = true;
  };

  patches = [
    ./patches/add-a-space-after-type-in-check-response-opt-sh.patch

    # https://github.com/dns-stats/compactor/pull/91
    ./patches/update-golden-cbor2diag-output.patch

    # https://github.com/dns-stats/compactor/commit/f7deaf89f55a12c586b6662a3a7d04b10a4c7bcb
    (fetchpatch {
      hash = "sha256-eEaVS5rfrLkRGc668PwVfb/xw3n1SoCm30xEf1NjbeY=";
      url = "https://github.com/dns-stats/compactor/commit/f7deaf89f55a12c586b6662a3a7d04b10a4c7bcb.patch";
    })
  ];

  postPatch = ''
    patchShebangs test-scripts/
    cp ${catch2}/include/catch2/catch.hpp tests/catch.hpp
  '';

  nativeBuildInputs = [
    asciidoctor
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boost186
    libctemplate
    libmaxminddb
    libpcap
    libtins
    openssl
    protobuf
    xz
    zlib
  ];

  configureFlags = [
    "--with-boost-libdir=${boost186.out}/lib"
    "--with-boost=${boost186.dev}"
  ];

  preConfigure = ''
    substituteInPlace configure \
      --replace "/usr/bin/file" "${file}/bin/file"
  '';

  doCheck = !stdenv.hostPlatform.isDarwin; # check-dnstap.sh failing on Darwin

  nativeCheckInputs = [
    cbor-diag
    cddl
    diffutils
    file
    mktemp
    netcat
    tcpdump
    wireshark-cli
  ];

  enableParallelBuilding = true;
  enableParallelInstalling = false; # race conditions when installing

  meta = {
    description = "Tools to capture DNS traffic and record it in C-DNS files";
    homepage = "https://dns-stats.org/";
    changelog = "https://github.com/dns-stats/compactor/raw/${finalAttrs.version}/ChangeLog.txt";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ fdns ];
    platforms = lib.platforms.unix;
  };
})
