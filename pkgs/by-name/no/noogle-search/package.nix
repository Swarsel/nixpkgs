{
  lib,
  fetchFromGitHub,
  bat,
  fzf,
  makeWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  xdg-utils,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noogle-search";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "argosnothing";
    repo = "noogle-search";
    tag = "v${finalAttrs.version}";
    hash = "sha256-js3jBZsyukleQW2BwggfYUvKCdS8pBTjD6ysWyMUtpI=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-axqFE5ZEiVP8PzFTtW5mbyyYcR4q9g3LX/0i6y+cgy8=";

  postInstall = ''
    wrapProgram $out/bin/noogle-search \
      --prefix PATH : ${
        lib.makeBinPath [
          bat
          fzf
          xdg-utils
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Search Noogle functions with fzf";
    homepage = "https://github.com/argosnothing/noogle-search";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ argos_nothing ];
    mainProgram = "noogle-search";
  };
})
