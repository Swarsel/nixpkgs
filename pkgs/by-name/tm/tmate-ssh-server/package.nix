{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cmake,
  libevent,
  libssh,
  libtool,
  msgpack-c,
  ncurses,
  nixosTests,
  openssl,
  pkg-config,
  ruby,
  zlib,
}:

stdenv.mkDerivation {
  pname = "tmate-ssh-server";
  version = "unstable-2023-06-02";

  src = fetchFromGitHub {
    owner = "tmate-io";
    repo = "tmate-ssh-server";
    rev = "d7334ee4c3c8036c27fb35c7a24df3a88a15676b";
    sha256 = "sha256-V3p0vagt13YjQPdqpbSatx5DnIEXL4t/kfxETSFYye0=";
  };

  postPatch = ''
    substituteInPlace configure.ac \
      --replace 'msgpack >= 1.2.0' 'msgpack-c >= 1.2.0'
  '';

  nativeBuildInputs = [
    autoreconfHook
    cmake
    pkg-config
  ];

  buildInputs = [
    libtool
    zlib
    openssl
    libevent
    ncurses
    ruby
    msgpack-c
    libssh
  ];

  dontUseCmakeConfigure = true;
  passthru.tests.tmate-ssh-server = nixosTests.tmate-ssh-server;

  meta = {
    description = "tmate SSH Server";
    homepage = "https://tmate.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ck3d ];
    platforms = lib.platforms.unix;
    mainProgram = "tmate-ssh-server";
  };
}
