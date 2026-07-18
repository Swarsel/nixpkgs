{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdfcrack";
  version = "0.21";

  src = fetchurl {
    url = "mirror://sourceforge/pdfcrack/pdfcrack/pdfcrack-${finalAttrs.version}.tar.gz";
    hash = "sha256-JvANSvy3C1g5BHvG9i5CUwc6xDe9tSbwHowEsiDpd2I=";
  };

  installPhase = ''
    install -Dt $out/bin pdfcrack
  '';

  meta = {
    description = "Small command line driven tool for recovering passwords and content from PDF files";
    homepage = "https://pdfcrack.sourceforge.net/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ qoelet ];
    platforms = lib.platforms.all;
    mainProgram = "pdfcrack";
  };
})
