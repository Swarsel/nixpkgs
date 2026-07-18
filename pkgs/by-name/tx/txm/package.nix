{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "txm";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "thatmagicalcat";
    repo = "txm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TV2vDQRH4KV+id7pPtG3Wjbfz/V60RS3wfIvKTP90iE=";
  };

  cargoHash = "sha256-ZGoIIPuDZUata7YmKOMCYcwc8Dlxo0s8W6eogK8qWsE=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal math rendering engine with LaTeX support";
    homepage = "https://github.com/thatmagicalcat/txm";
    changelog = "https://github.com/thatmagicalcat/txm/releases/tag/v${finalAttrs.src.tag}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ DuskyElf ];
    platforms = lib.platforms.all;
    mainProgram = "txm";
  };
})
