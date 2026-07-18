{
  lib,
  fetchurl,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cm-unicode";
  version = "0.7.0";

  src = fetchurl {
    url = "mirror://sourceforge/cm-unicode/cm-unicode/${finalAttrs.version}/cm-unicode-${finalAttrs.version}-otf.tar.xz";
    hash = "sha256-VIp+vk1IYbEHW15wMrfGVOPqg1zBZDpgFx+jlypOHCg=";
  };

  nativeBuildInputs = [ installFonts ];

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/doc/cm-unicode-${finalAttrs.version}    README FontLog.txt

    runHook postInstall
  '';

  meta = {
    description = "Computer Modern Unicode fonts";
    homepage = "https://cm-unicode.sourceforge.io/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      raskin
      rycee
    ];

    platforms = lib.platforms.all;
  };
})
