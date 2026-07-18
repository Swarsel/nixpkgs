{
  lib,
  stdenv,
  libagar,
  libjpeg,
  libpng,
  openssl,
  perl,
}:
stdenv.mkDerivation {
  inherit (libagar) version src;
  pname = "libagar-test";

  buildInputs = [
    perl
    libagar
    libjpeg
    libpng
    openssl
  ];

  configureFlags = [ "--with-agar=${libagar}" ];
  sourceRoot = "agar-${libagar.version}/tests";

  meta = {
    description = "Tests for libagar";
    homepage = "http://libagar.org/index.html";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ ramkromberg ];
    platforms = lib.platforms.linux;
    mainProgram = "agartest";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
}
