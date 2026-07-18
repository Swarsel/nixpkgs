{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cunit,
  libtool,
  libxcrypt,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dcap";
  version = "2.47.14";

  src = fetchFromGitHub {
    owner = "dCache";
    repo = "dcap";
    rev = finalAttrs.version;
    sha256 = "sha256-hn4nkFTIbSUUhvf9UfsEqVhphAdNWmATaCrv8jOuC0Y=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    zlib
    libxcrypt
  ];

  preConfigure = ''
    patchShebangs --build bootstrap.sh
    ./bootstrap.sh
  '';

  doCheck = true;
  checkInputs = [ cunit ];

  meta = {
    description = "dCache access protocol client library";
    homepage = "https://github.com/dCache/dcap";
    changelog = "https://github.com/dCache/dcap/blob/master/ChangeLog";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    platforms = lib.platforms.all;
    mainProgram = "dccp";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
