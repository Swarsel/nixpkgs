{
  lib,
  stdenv,
  fetchurl,
  libx11,
  perl,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ratmen";
  version = "2.2.3";

  src = fetchurl {
    url = "http://www.update.uu.se/~zrajm/programs/ratmen/ratmen-${finalAttrs.version}.tar.gz";
    sha256 = "0gnfqhnch9x8jhr87gvdjcp1wsqhchfjilpnqcwx5j0nlqyz6wi6";
  };

  buildInputs = [
    perl
    xorgproto
    libx11
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = {
    description = "Minimalistic X11 menu creator";
    homepage = "http://www.update.uu.se/~zrajm/programs/";
    license = lib.licenses.free; # 9menu derivative with 9menu license
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "ratmen";
    downloadPage = "http://www.update.uu.se/~zrajm/programs/ratmen/";
  };
})
