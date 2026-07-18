{
  lib,
  fetchFromGitHub,
  alsa-lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ting";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dhth";
    repo = "ting";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D5u/zRjUu+fku6MdtBuwjYQqCkaQbI4sN0UR5NLFN8c=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];
  cargoHash = "sha256-17hmYsbOOJcrepwI4Q6VuB42SF7ec+BJYTlGKmxkL5w=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Audio feedback on the command line";
    homepage = "https://github.com/dhth/ting";
    changelog = "https://github.com/dhth/ting/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yiyu ];
    platforms = lib.platforms.linux;
    mainProgram = "ting";
  };
})
