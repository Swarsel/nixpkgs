{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "riemann";
  version = "0.3.12";

  src = fetchurl {
    url = "https://github.com/riemann/riemann/releases/download/${finalAttrs.version}/riemann-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-gsJMfLo7zpaVfyVmHznGFiomK6dq7yTphuc9vyp5t6Y=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    substituteInPlace bin/riemann --replace '$top/lib/riemann.jar' "$out/share/java/riemann.jar"

    mkdir -p $out/share/java $out/bin $out/etc
    mv lib/riemann.jar $out/share/java/
    mv bin/riemann $out/bin/
    mv etc/riemann.config $out/etc/

    wrapProgram "$out/bin/riemann" --prefix PATH : "${jre}/bin"
  '';

  meta = {
    description = "Network monitoring system";
    homepage = "http://riemann.io/";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ crimeminister ];
    platforms = lib.platforms.all;
    mainProgram = "riemann";
  };
})
