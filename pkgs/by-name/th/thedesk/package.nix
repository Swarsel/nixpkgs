{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  dpkg,
  gtk3,
  libGL,
  libgbm,
  libxshmfence,
  makeWrapper,
  musl,
  nss,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thedesk";
  version = "25.3.1";

  src = fetchurl {
    url = "https://github.com/cutls/thedesk-next/releases/download/v${finalAttrs.version}/thedesk-next_${finalAttrs.version}_amd64.deb";
    hash = "sha256-DNZVHSd9dG4h6lv0PoUUaBaA/ijJJtX8d9Qy5iPdLoc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    gtk3
    libgbm
    libGL
    libxshmfence
    musl
    nss
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace usr/share/applications/thedesk-next.desktop \
      --replace-fail "/opt/TheDesk/thedesk-next" "thedesk"
    cp --recursive usr $out
    mkdir $out/libexec $out/bin
    cp --recursive opt/TheDesk $out/libexec/thedesk
    ln --symbolic $out/libexec/thedesk/thedesk-next $out/bin/thedesk

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 $out/libexec/thedesk/thedesk-next
  '';

  runtimeDependencies = [ systemd ];

  meta = {
    description = "Mastodon/Misskey Client for PC";
    homepage = "https://thedesk.top";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "thedesk";
  };
})
