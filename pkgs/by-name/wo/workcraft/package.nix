{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "workcraft";
  version = "3.5.5";

  src = fetchurl {
    url = "https://github.com/workcraft/workcraft/releases/download/v${finalAttrs.version}/workcraft-v${finalAttrs.version}-linux.tar.gz";
    hash = "sha256-zpuwNwVu9iH7JSHsSyGt3gl6swOHa2b9uDC8Ck2Mtno=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share
    cp -r * $out/share
    mkdir $out/bin
    makeWrapper $out/share/workcraft $out/bin/workcraft \
      --set JAVA_HOME "${jre}" \
      --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp";
  '';

  dontConfigure = true;

  meta = {
    description = "Framework for interpreted graph modeling, verification and synthesis";
    homepage = "https://workcraft.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ timor ];
    platforms = lib.platforms.linux;
    mainProgram = "workcraft";
  };
})
