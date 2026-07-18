{
  lib,
  stdenv,
  fetchurl,
  fortune,
  libiconv,
  makeWrapper,
  ncurses,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtypist";
  version = "2.10.1";

  src = fetchurl {
    url = "mirror://gnu/gtypist/gtypist-${finalAttrs.version}.tar.xz";
    hash = "sha256-ymGAVOkfHtXvBD/MQ1ALutcByVnDGETUaI/yKEmsJS0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    ncurses
    perl
    fortune
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  env.CFLAGS = "-std=gnu99";

  preFixup = ''
    wrapProgram "$out/bin/typefortune" \
      --prefix PATH : "${fortune}/bin"
  '';

  meta = {
    description = "Universal typing tutor";
    homepage = "https://www.gnu.org/software/gtypist";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
