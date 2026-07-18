{
  lib,
  stdenv,
  fetchurl,
  file,
  libjpeg,
  libpng,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "farbfeld";
  version = "4";

  src = fetchurl {
    url = "https://dl.suckless.org/farbfeld/farbfeld-${finalAttrs.version}.tar.gz";
    sha256 = "0ap7rcngffhdd57jw9j22arzkbrhwh0zpxhwbdfwl8fixlhmkpy7";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    libpng
    libjpeg
  ];

  makeFlags = [ "CC:=$(CC)" ];

  postInstall = ''
    wrapProgram "$out/bin/2ff" --prefix PATH : "${file}/bin"
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Suckless image format with conversion tools";
    homepage = "https://tools.suckless.org/farbfeld/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
  };
})
