{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  curl,
  expat,
  libuuid,
  libvirt,
  libxml2,
  munge,
  openssl,
  pcre2,
  perl,
  python3,
  scitokens-cpp,
  sqlite,
  voms,
}:

stdenv.mkDerivation rec {
  pname = "htcondor";
  version = "24.2.2";

  src = fetchFromGitHub {
    owner = "htcondor";
    repo = "htcondor";
    rev = "v${version}";
    hash = "sha256-F8uI8Stvao7VKULTcOjv/nFUhFHxqd00gRNe6tkKgPE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libuuid
    expat
    openssl
    curl
    pcre2
    sqlite
    python3
    boost
    libxml2
    libvirt
    munge
    voms
    perl
    scitokens-cpp
  ];

  cmakeFlags = [
    "-DSYSTEM_NAME=NixOS"
    "-DWITH_PYTHON_BINDINGS=false"
  ];

  env.CXXFLAGS = "-fpermissive";

  meta = {
    description = "Software system that creates a High-Throughput Computing (HTC) environment";
    homepage = "https://htcondor.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evey ];
    platforms = lib.platforms.linux;
    # On Aarch64: ld: cannot find -lpthread: No such file or directory
    # On x86_64:  ld: cannot find -ldl:      No such file or directory
    broken = true;
  };
}
