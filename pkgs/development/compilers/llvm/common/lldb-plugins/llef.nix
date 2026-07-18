{
  lib,
  stdenv,
  fetchFromGitHub,
  lldb,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "llef";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "foundryzero";
    repo = "llef";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pUZ2d9ch1mQzfWqHy0srOJwNULGH7dUgVapCaImLa0g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/llef
    cp -r llef.py arch commands common handlers $out/share/llef
    makeWrapper ${lib.getExe lldb} $out/bin/llef \
      --add-flags "-o 'settings set stop-disassembly-display never'" \
      --add-flags "-o \"command script import $out/share/llef/llef.py\""

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "LLEF is a plugin for LLDB to make it more useful for RE and VR";
    homepage = "https://github.com/foundryzero/llef";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nrabulinski ];
    platforms = lib.platforms.all;
    mainProgram = "llef";
  };
})
