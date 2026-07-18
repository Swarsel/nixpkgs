{
  lib,
  fetchFromGitHub,
  buildGo125Module,
  dbus,
  nix-update-script,
  versionCheckHook,
}:

buildGo125Module (finalAttrs: {
  pname = "upcloud-cli";
  version = "3.29.0";

  src = fetchFromGitHub {
    owner = "UpCloudLtd";
    repo = "upcloud-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4TsXif8jO8NvoHFXSLbkQ3lJltUa54ESbtBwAncPXQ4=";
  };

  vendorHash = "sha256-d4YYTQhAmTvf2JCN2f9XaDchXyc/6Fg5KNkY0QH9viQ=";
  nativeCheckInputs = [ dbus ];

  checkFlags =
    let
      skippedTests = [
        "TestConfig_LoadKeyring" # Not equal: expected: "unittest_password" actual  : ""
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s -w -X github.com/UpCloudLtd/upcloud-cli/v3/internal/config.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/upctl"
    "internal/*"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/upctl";
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for managing UpCloud services";
    homepage = "https://github.com/UpCloudLtd/upcloud-cli";
    changelog = "https://github.com/UpCloudLtd/upcloud-cli/blob/refs/tags/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lu1a ];
    mainProgram = "upctl";
  };
})
