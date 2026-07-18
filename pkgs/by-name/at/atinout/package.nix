{
  lib,
  stdenv,
  fetchgit,
  mount,
  ronn,
}:

stdenv.mkDerivation {
  pname = "atinout";
  version = "0.9.2-alpha";

  src = fetchgit {
    url = "git://git.code.sf.net/p/atinout/code";
    rev = "4976a6cb5237373b7e23cd02d7cd5517f306e3f6";
    sha256 = "0bninv2bklz7ly140cxx8iyaqjlq809jjx6xqpimn34ghwsaxbpv";
  };

  nativeBuildInputs = [
    ronn
    mount
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  env = {
    LANG = if stdenv.hostPlatform.isDarwin then "en_US.UTF-8" else "C.UTF-8";
  }
  // lib.optionalAttrs (!stdenv.cc.isClang) {
    NIX_CFLAGS_COMPILE = "-Werror=implicit-fallthrough=0";
  };

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = {
    description = "Tool for talking to modems";
    homepage = "https://atinout.sourceforge.net";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ bendlas ];
    platforms = lib.platforms.unix;
    mainProgram = "atinout";
  };
}
