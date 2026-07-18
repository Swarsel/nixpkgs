{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "onestepback";
  version = "0.997";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p  $out/share/themes
    cp -a OneStepBack* $out/share/themes/
    rm $out/share/themes/*/{LICENSE,README*}
    runHook postInstall
  '';

  sourceRoot = ".";

  srcs = [
    (fetchurl {
      hash = "sha256-uB6pfnTkMKeP71rAvn1olJJeCL84222UT5uxG72sywE=";
      url = "http://www.vide.memoire.free.fr/pages/onestepback/OneStepBack-v${finalAttrs.version}.zip";
    })
    (fetchurl {
      hash = "sha256-Zdv4ZrQPficbCxPBKF3RFNavlSn/VV/efiZVUT86zRc=";
      url = "http://www.vide.memoire.free.fr/pages/onestepback/OneStepBack-wm2-v${finalAttrs.version}.zip";
    })
  ];

  meta = {
    description = "Gtk theme inspired by the NextStep look";
    homepage = "http://www.vide.memoire.free.fr/pages/onestepback";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.all;
  };
})
