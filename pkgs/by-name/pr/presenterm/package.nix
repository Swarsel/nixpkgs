{
  lib,
  stdenv,
  fetchFromGitHub,
  lld,
  makeBinaryWrapper,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
let
  inherit (stdenv.hostPlatform) isDarwin isx86_64;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "presenterm";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "mfontanini";
    repo = "presenterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mIJktrgBweaaLD2YaRcs0vP5hKRy/kMN/HEnwO323DA=";
  };

  nativeBuildInputs =
    lib.optionals isDarwin [
      makeBinaryWrapper
    ]
    ++ lib.optionals (isDarwin && isx86_64) [
      lld
    ];

  cargoHash = "sha256-OlZXf8Wg32mXGDGbavLVf1ELoqqSmc8z9DNpvGOfAJ8=";

  env = lib.optionalAttrs (isDarwin && isx86_64) {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  checkFlags = [
    # failed to load .tmpEeeeaQ: No such file or directory (os error 2)
    "--skip=external_snippet"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Terminal based slideshow tool";
    homepage = "https://github.com/mfontanini/presenterm";
    changelog = "https://github.com/mfontanini/presenterm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      GaetanLepage
      mikaelfangel
    ];

    mainProgram = "presenterm";
  };
})
