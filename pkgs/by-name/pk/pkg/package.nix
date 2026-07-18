{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  elfutils,
  libarchive,
  libbsd,
  m4,
  openssl,
  pkg-config,
  tcl,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pkg";
  version = "2.7.5";

  src = fetchFromGitHub {
    owner = "freebsd";
    repo = "pkg";
    rev = finalAttrs.version;
    hash = "sha256-t1Mvnw6dRbKgUjxSnm4OSbq8HN6e/0q2MqUlgNB+amw=";
  };

  nativeBuildInputs = [
    m4
    pkg-config
    tcl
  ];

  buildInputs = [
    bzip2
    elfutils
    libarchive
    openssl
    xz
    zlib
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libbsd;

  preInstall = ''
    mkdir -p $out/etc
  '';

  enableParallelBuilding = true;
  separateDebugInfo = true;
  setOutputFlags = false;

  meta = {
    description = "Package management tool for FreeBSD";
    homepage = "https://github.com/freebsd/pkg";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = with lib.platforms; darwin ++ freebsd ++ linux ++ netbsd ++ openbsd;
    mainProgram = "pkg";
  };
})
