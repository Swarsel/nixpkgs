{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "git-pages-cli";
  version = "1.10.0";

  src = fetchFromCodeberg {
    owner = "git-pages";
    repo = "git-pages-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GIZ6kdCd8BIBEZxBw4Srwnbbl3PtpS2IRyA+Hx5PbAc=";
  };

  vendorHash = "sha256-SNLSkz38AgLfjpKaEYawBLdWznKWOz62bNzuaquk7Rs=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-X"
    "main.versionOverride=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.*)"
    ];
  };

  meta = {
    description = "Command-line application for uploading a site to a git-pages server";
    homepage = "https://codeberg.org/git-pages/git-pages-cli";
    changelog = "https://codeberg.org/git-pages/git-pages-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ dramforever ];
    mainProgram = "git-pages-cli";
  };
})
