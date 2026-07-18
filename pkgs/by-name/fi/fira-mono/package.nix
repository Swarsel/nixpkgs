{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-mono";
  version = "3.2";

  src = fetchzip {
    url = "https://carrois.com/downloads/Fira/Fira_Mono_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }.zip";

    hash = "sha256-Ukc+K2sdSz+vUQFD8mmwJHZQ3N68oM4fk6YzGLwzAfQ=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Monospace font for Firefox OS";

    longDescription = ''
      Fira Mono is a monospace font designed by Erik Spiekermann,
      Ralph du Carrois, Anja Meiners and Botio Nikoltchev of Carrois
      Type Design for Mozilla Firefox OS. Available in Regular,
      Medium, and Bold.
    '';

    homepage = "https://carrois.com/fira/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
})
