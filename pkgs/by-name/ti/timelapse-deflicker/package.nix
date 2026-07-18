{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "timelapse-deflicker";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "cyberang3l";
    repo = "timelapse-deflicker";
    rev = "v${finalAttrs.version}";
    sha256 = "0bbfnrdycrpyz7rqrql5ib9qszny7z5xpqp65c1mxqd2876gv960";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with perlPackages; [
    perl
    ImageMagick
    TermProgressBar
    ImageExifTool
    FileType
    ClassMethodMaker
  ];

  installPhase = ''
    install -m755 -D timelapse-deflicker.pl $out/bin/timelapse-deflicker
    wrapProgram $out/bin/timelapse-deflicker --set PERL5LIB $PERL5LIB
  '';

  meta = {
    description = "Simple script to deflicker images taken for timelapses";
    homepage = "https://github.com/cyberang3l/timelapse-deflicker";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ valeriangalliat ];
    platforms = lib.platforms.unix;
    mainProgram = "timelapse-deflicker";
  };
})
