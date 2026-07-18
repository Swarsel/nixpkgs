{
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  niri,
  nix-update-script,
  rustPlatform,
  stardust-xr-kiara,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stardust-xr-kiara";
  version = "0-unstable-2024-07-13";

  src = fetchFromGitHub {
    owner = "stardustxr";
    repo = "kiara";
    rev = "186b00a460c9dd8179f9af42fb9a420506ac3aff";
    hash = "sha256-e89/x66S+MpJFtqat1hYEyRVUYFjef62LDN2hQPjNVw=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  cargoHash = "sha256-C1eD974cEGbo0vHJqdnCPUopDPDDa6hAFJdzSm8t618=";

  env = {
    NIRI_CONFIG = "${finalAttrs.src}/src/niri_config.kdl";
    STARDUST_RES_PREFIXES = "${finalAttrs.src}/res";
  };

  postInstall = ''
    wrapProgram $out/bin/kiara --prefix PATH : ${niri}/bin
  '';

  passthru = {
    tests.helpTest = testers.runCommand {
      nativeBuildInputs = [ stardust-xr-kiara ];
      name = "stardust-xr-kiara";

      script = ''
        kiara --help
        touch $out
      '';
    };

    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "360-degree app shell / DE for Stardust XR using Niri";
    homepage = "https://stardustxr.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pandapip1
      technobaboo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "kiara";
  };
})
