{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libpcap,
  lksctp-tools,
  ncurses,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sipp";
  version = "3.7.7";

  src = fetchFromGitHub {
    owner = "SIPp";
    repo = "sipp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1JKKD3rEddCzXrbNpbzvhFXlTlkTXlP7vmRXvlGzkgI=";
  };

  postPatch = ''
    echo '#define SIPP_VERSION VERSION' > include/version.h
    echo '#define VERSION "v${finalAttrs.version}"' >> include/version.h
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    ncurses
    libpcap
    openssl
  ]
  ++ lib.optional (stdenv.hostPlatform.isLinux) lksctp-tools;

  cmakeFlags = [
    "-DUSE_PCAP=1"
    "-DUSE_SSL=1"
    "-DUSE_SCTP=${if stdenv.hostPlatform.isLinux then "1" else "0"}"

    # file RPATH_CHANGE could not write new RPATH
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "SIPp testing tool";
    homepage = "http://sipp.sf.net";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "sipp";
  };
})
