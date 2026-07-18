{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  boost,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mini-httpd";
  version = "1.7";

  src = fetchurl {
    url = "https://download-mirror.savannah.gnu.org/releases/mini-httpd/mini-httpd-${finalAttrs.version}.tar.gz";
    sha256 = "0jggmlaywjfbdljzv5hyiz49plnxh0har2bnc9dq4xmj1pmjgs49";
  };

  patches = [
    ./remove-boost-system.patch
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ boost ];
  env.NIX_CFLAGS_COMPILE = toString [ "-std=c++14" ];
  enableParallelBuilding = true;

  meta = {
    description = "Minimalistic high-performance web server";
    homepage = "http://mini-httpd.nongnu.org/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.peti ];
    platforms = lib.platforms.linux;
    mainProgram = "httpd";
  };
})
