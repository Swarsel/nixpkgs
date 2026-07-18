{
  lib,
  stdenv,
  fetchurl,
  libnetfilter_conntrack,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iptstate";
  version = "2.2.7";

  src = fetchurl {
    url = "https://github.com/jaymzh/iptstate/releases/download/v${finalAttrs.version}/iptstate-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-iW3wYCiFRWomMfeV1jT8ITEeUF+MkQNI5jEoYPIJeVU=";
  };

  buildInputs = [
    libnetfilter_conntrack
    ncurses
  ];

  installPhase = ''
    install -m755 -D iptstate $out/bin/iptstate
  '';

  meta = {
    description = "Conntrack top like tool";
    homepage = "https://github.com/jaymzh/iptstate";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ trevorj ];
    platforms = lib.platforms.linux;
    mainProgram = "iptstate";
    downloadPage = "https://github.com/jaymzh/iptstate/releases";
  };
})
