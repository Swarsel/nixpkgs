{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libcap,
  libnetfilter_conntrack,
  libnetfilter_queue,
  libnfnetlink,
  libpcap,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tcpcrypt";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "scslab";
    repo = "tcpcrypt";
    rev = "v${finalAttrs.version}";
    sha256 = "0a015rlyvagz714pgwr85f8gjq1fkc0il7d7l39qcgxrsp15b96w";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    libpcap
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
    libnfnetlink
    libnetfilter_conntrack
    libnetfilter_queue
  ];

  enableParallelBuilding = true;
  postUnpack = "mkdir -vp $sourceRoot/m4";

  meta = {
    description = "Fast TCP encryption";
    homepage = "http://tcpcrypt.org/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
