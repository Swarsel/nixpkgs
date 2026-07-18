{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_net,
  alsa-lib,
  cmake,
  discord-rpc,
  fluidsynth,
  libebur128,
  libsndfile,
  libxmp,
  nix-update-script,
  openal,
  python3,
  yyjson,
  withDiscordRpc ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "woof-doom";
  version = "15.3.0";

  src = fetchFromGitHub {
    owner = "fabiangreffrath";
    repo = "woof";
    tag = "woof_${finalAttrs.version}";
    hash = "sha256-G9exAJivfZnT2eWQhFYT8ZVRUU1QT0VAZF1CDCXmJ04=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_net
    fluidsynth
    libsndfile
    libxmp
    libebur128
    openal
    yyjson
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ]
  ++ lib.optional withDiscordRpc discord-rpc;

  cmakeFlags = [
    (lib.cmakeBool "WITH_DISCORD_RPC" withDiscordRpc)
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "woof_(.*)"
    ];
  };

  meta = {
    description = "Doom source port based on Boom/MBF";
    homepage = "https://github.com/fabiangreffrath/woof";
    changelog = "https://github.com/fabiangreffrath/woof/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = lib.platforms.unix;
    mainProgram = "woof";
  };
})
