{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cairo,
  libx11,
  libxcomposite,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libaosd";
  version = "0.2.7-9-g177589f";

  src = fetchFromGitHub {
    owner = "atheme-legacy";
    repo = "libaosd";
    rev = finalAttrs.version;
    sha256 = "1cn7k0n74p6jp25kxwcyblhmbdvgw3mikvj0m2jh4c6xccfrgb9a";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    cairo
    pango
    libx11
    libxcomposite
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  meta = {
    longDescription = ''
      libaosd is an advanced on screen display library.

      It supports many modern features like anti-aliased text and
      composited rendering via XComposite, as well as support for
      rendering Cairo and Pango layouts.
    '';

    homepage = "https://github.com/atheme-legacy/libaosd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unode ];
    platforms = with lib.platforms; unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
