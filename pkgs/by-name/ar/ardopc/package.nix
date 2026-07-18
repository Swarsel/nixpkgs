{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  flrig,
  hamlib,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ardopc";
  version = "unstable-2021-08-28";

  src = fetchFromGitHub {
    owner = "hamarituc";
    repo = "ardop";
    tag = "20210828";
    hash = "sha256-OUw9spFTsQLnsXksbfl3wD2NyY40JTyvlvONEIeZyWo=";
  };

  postPatch = ''
    substituteInPlace pktSession.c \
      --replace-fail 'VOID L2SENDCOMMAND();' 'VOID L2SENDCOMMAND(struct _LINKTABLE * LINK, int CMD);' \
      --replace-fail 'VOID CONNECTFAILED();' 'VOID CONNECTFAILED(struct _LINKTABLE * LINK);'
    substituteInPlace ARDOPC.h \
      --replace-fail 'BOOL CheckForPktData();' 'BOOL CheckForPktData(int Channel);'
    substituteInPlace ALSASound.c \
      --replace-fail 'void InitSound(BOOL Quiet)' 'void InitSound()'
    substituteInPlace ARQ.c \
      --replace-fail 'SendData(FALSE);' 'SendData();'
    substituteInPlace Modulate.c \
      --replace-fail 'SoundFlush(Number);' 'SoundFlush();'
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    flrig
    hamlib
  ];

  installPhase = ''
    runHook preInstall

    install -D ardopc $out/bin/ardopc

    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/ARDOPC";

  meta = {
    description = "ARDOP (Amateur Radio Digital Open Protocol) TNC implementation by John Wiseman (GM8BPQ)";
    homepage = "https://github.com/hamarituc/ardop/ARDOPC";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ oliver-koss ];
    platforms = lib.platforms.all;
    mainProgram = "ardopc";
  };
})
