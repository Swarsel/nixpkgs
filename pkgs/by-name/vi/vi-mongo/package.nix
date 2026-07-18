{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "vi-mongo";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "kopecmaciej";
    repo = "vi-mongo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wPijV+5wTZWG60E2Tdp+mj75eh8go6JVZF2JTcp1Ais=";
  };

  vendorHash = "sha256-CuFoH6crS6BOsSj2hNGw7loi4RixHbyJGySfxglUUmg=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X=github.com/kopecmaciej/vi-mongo/internal/build.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MongoDB TUI manager designed to simplify data visualization and quick manipulation";
    homepage = "https://github.com/kopecmaciej/vi-mongo";
    changelog = "https://github.com/kopecmaciej/vi-mongo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "vi-mongo";
  };
})
