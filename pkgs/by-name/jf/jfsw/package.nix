{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  gtk3,
  perl,
  pkg-config,
  which,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jfsw";
  version = "20260105";

  src = fetchFromGitHub {
    owner = "jonof";
    repo = "jfsw";
    tag = finalAttrs.version;
    hash = "sha256-L/EtdbyU6uZbSajQkI8IclskIfzm15uikSK2EZZZHXA=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    which
    SDL2
    perl
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 sw -t $out/bin

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    inherit (SDL2.meta) platforms;
    description = "Modern port the original Shadow Warrior";
    homepage = "http://www.jonof.id.au/jfsw/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ moody ];
    mainProgram = "sw";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
