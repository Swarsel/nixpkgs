{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stops";
  version = "0.4.0";

  src = fetchurl {
    url = "https://kokkinizita.linuxaudio.org/linuxaudio/downloads/stops-${finalAttrs.version}.tar.bz2";
    hash = "sha256-DnmguOAGyw9nv88ekJfbC04Qwbsw5tXEAaKeiCQR/LA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/Aeolus/stops
    cp -r * $out/share/Aeolus/stops

    runHook postInstall
  '';

  outputHash = "sha256-gGHowq7g7MZmnhrpqG+3wNLwQCtpiBB88euIKeQIpJ0=";
  outputHashMode = "recursive";

  meta = {
    description = "Aeolus synthesizer instrument definitions";
    homepage = "http://kokkinizita.linuxaudio.org/linuxaudio/aeolus/index.html";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      nico202
    ];

    platforms = lib.platforms.linux;
  };
})
