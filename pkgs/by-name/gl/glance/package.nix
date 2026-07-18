{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "glance";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WFX1Gca7ign9i1zOQ9lRdtOSGq9QG33vIA5QTnq9E8=";
  };

  vendorHash = "sha256-a92V/duqvrWEb8QSJLA5rHYYZCcJ4fBC962SEr4FJDA=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/glanceapp/glance/internal/glance.buildVersion=v${finalAttrs.version}"
  ];

  passthru = {
    tests = {
      service = nixosTests.glance;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Self-hosted dashboard that puts all your feeds in one place";
    homepage = "https://github.com/glanceapp/glance";
    changelog = "https://github.com/glanceapp/glance/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      dvn0
      defelo
    ];

    mainProgram = "glance";
  };
})
