{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "geteduroam-cli";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "geteduroam";
    repo = "linux-app";
    tag = finalAttrs.version;
    hash = "sha256-Zvyba8ma4a5WmV6rnfUKqQ8AsZlGGWrZsL8UZIWApTQ=";
  };

  vendorHash = "sha256-HYJ71pk1a8EaPycmbHmMnQeb42dt7M9NvK/1GYhZE0c=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  subPackages = [
    "cmd/geteduroam-cli"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/geteduroam-cli";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI client to configure eduroam";
    homepage = "https://github.com/geteduroam/linux-app";
    changelog = "https://github.com/geteduroam/linux-app/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ viperML ];
    platforms = lib.platforms.linux;
    mainProgram = "geteduroam-cli";
  };
})
