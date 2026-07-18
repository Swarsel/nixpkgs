{
  lib,
  stdenv,
  fetchurl,
  exif,
  imagemagick,
  makeWrapper,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "recoverjpeg";
  version = "2.6.3";

  src = fetchurl {
    url = "https://www.rfc1149.net/download/recoverjpeg/recoverjpeg-${finalAttrs.version}.tar.gz";
    sha256 = "009jgxi8lvdp00dwfj0n4x5yqrf64x00xdkpxpwgl2v8wcqn56fv";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  postFixup = ''
    wrapProgram $out/bin/sort-pictures \
      --prefix PATH : ${
        lib.makeBinPath [
          exif
          imagemagick
        ]
      }
  '';

  meta = {
    description = "Recover lost JPEGs and MOV files on a bogus memory card or disk";
    homepage = "https://rfc1149.net/devel/recoverjpeg.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = with lib.platforms; linux;
  };
})
