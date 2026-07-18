{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  vulkan-loader,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "binocle";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "binocle";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-WAk7xIrCRfVofn4w+gP5E3wnSZbXm/6MZWlNmtoLm20=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  cargoHash = "sha256-AUmDubbi6y1SaHZazr2xZc+16SQhI6WBnPg6I7rv3K4=";

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    wrapProgram $out/bin/binocle \
      --suffix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libx11
          libxcursor
          libxi
          libxrandr
          vulkan-loader
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Graphical tool to visualize binary data";
    homepage = "https://github.com/sharkdp/binocle";
    changelog = "https://github.com/sharkdp/binocle/releases/tag/v0.3.2";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "binocle";
  };
})
