{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-sans";
  version = "4.301";

  src = fetchzip {
    url = "https://carrois.com/downloads/Fira/Download_Folder_FiraSans_${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }.zip";

    hash = "sha256-WBt3oqPK7ACqMhilYkyFx9Ek2ugwdCDFZN+8HLRnGRs";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  preInstall = ''
    rm -r "__MACOSX"
  '';

  meta = {
    description = "Sans-serif font for Firefox OS";

    longDescription = ''
      Fira Sans is a sans-serif font designed by Erik Spiekermann,
      Ralph du Carrois, Anja Meiners and Botio Nikoltchev of Carrois
      Type Design for Mozilla Firefox OS.  It is closely related to
      Spiekermann's FF Meta typeface.  Available in Two, Four, Eight,
      Hair, Thin, Ultra Light, Extra Light, Light, Book, Regular,
      Medium, Semi Bold, Bold, Extra Bold, Heavy weights with
      corresponding italic versions.
    '';

    homepage = "https://carrois.com/fira/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})
