{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "twitch-hls-client";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "2bc4";
    repo = "twitch-hls-client";
    rev = finalAttrs.version;
    hash = "sha256-6b0EX7ykeYSUvfT03Ot6JiFk7EETF5b69FhnGZb6prI=";
  };

  cargoHash = "sha256-YBgQEkNglhrmrELpd88LYZaExheHHU32a+CUsBgxfoY=";

  meta = {
    description = "Minimal CLI client for watching/recording Twitch streams";
    homepage = "https://github.com/2bc4/twitch-hls-client.git";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ lenivaya ];
    platforms = lib.platforms.all;
    mainProgram = "twitch-hls-client";
  };
})
