{
  lib,
  stdenv,
  pkgs,
}:

stdenv.mkDerivation {
  pname = "ecdsatool";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "kaniini";
    repo = "ecdsatool";
    rev = "7c0b2c51e2e64d1986ab1dc2c57c2d895cc00ed1";
    sha256 = "08z9309znkhrjpwqd4ygvm7cd1ha1qbrnlzw64fr8704jrmx762k";
  };

  patches = [
    ./ctype-header-c99-implicit-function-declaration.patch
    ./openssl-header-c99-implicit-function-declaration.patch
  ];

  nativeBuildInputs = with pkgs; [
    openssl
    autoconf
    automake
  ];

  buildInputs = with pkgs; [ libuecc ];

  configurePhase = ''
    runHook preConfigure

    ./autogen.sh
    ./configure --prefix=$out

    runHook postConfigure
  '';

  meta = {
    description = "Create and manipulate ECC NISTP256 keypairs";
    homepage = "https://github.com/kaniini/ecdsatool/";
    license = with lib.licenses; [ free ];
    platforms = lib.platforms.unix;
    mainProgram = "ecdsatool";
  };
}
