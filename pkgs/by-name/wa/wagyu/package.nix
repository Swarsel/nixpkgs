{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wagyu";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "AleoHQ";
    repo = "wagyu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5n8BmETv5jUvgu0rskAPYaBgYyNL2QU2t/iUb3hNMMw=";
  };

  cargoHash = "sha256-vtNxRW/b8kvy21YQezCUiZNtLnlMSkdTRr/OkGy6UAw=";
  cargoPatches = [ ./fix-rustc-serialize-version.patch ];

  meta = {
    description = "Rust library for generating cryptocurrency wallets";
    homepage = "https://github.com/AleoHQ/wagyu";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = [ ];
    mainProgram = "wagyu";
  };
})
