{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchzip,
}:

stdenv.mkDerivation rec {
  pname = "discord-gamesdk";
  version = "3.2.1";

  src = fetchzip {
    url = "https://dl-game-sdk.discordapp.net/${version}/discord_game_sdk.zip";
    hash = "sha256-83DgL9y3lHLLJ8vgL3EOVk2Tjcue64N+iuDj/UpSdLc=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = [ (stdenv.cc.cc.libgcc or null) ];

  installPhase =
    let
      processor = stdenv.hostPlatform.parsed.cpu.name;
      sharedLibrary = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      runHook preInstall

      install -Dm555 lib/${processor}/discord_game_sdk${sharedLibrary} $out/lib/discord_game_sdk${sharedLibrary}

      install -Dm444 c/discord_game_sdk.h $dev/lib/include/discord_game_sdk.h

      runHook postInstall
    '';

  meta = {
    description = "Library to allow other programs to interact with the Discord desktop application";
    homepage = "https://discord.com/developers/docs/game-sdk/sdk-starter-guide";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ tomodachi94 ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-windows"
    ];
  };
}
