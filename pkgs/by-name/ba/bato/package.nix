{
  lib,
  fetchFromGitHub,
  cmake,
  libnotify,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bato";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "doums";
    repo = "bato";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pq+i4NGl7yv+vmMoYVT9JRvOsuV7nBqXpsebgMcNEY0=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [ libnotify ];
  cargoHash = "sha256-ZVzIoq+s2Xw996NoQMIGHUqo2uXJMu9lXfY5Us9NMPg=";

  meta = {
    description = "Small program to send battery notifications";
    homepage = "https://github.com/doums/bato";
    changelog = "https://github.com/doums/bato/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ HaskellHegemonie ];
    platforms = lib.platforms.linux;
    mainProgram = "bato";
  };
})
