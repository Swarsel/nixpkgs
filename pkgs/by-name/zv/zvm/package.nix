{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "zvm";
  version = "0.8.22";

  src = fetchFromGitHub {
    owner = "tristanisham";
    repo = "zvm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uKn4ysaNuvWpV4fhrpm7pdS61pQJTYr6WfIhBzTfNT8=";
  };

  vendorHash = "sha256-kJrCUxzbpyxEUF9UQeAI28tWKA+T7zT1DBI1wf3pjjM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to manage and use different Zig versions";
    homepage = "https://www.zvm.app/";
    changelog = "https://github.com/tristanisham/zvm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "zvm";
    downloadPage = "https://github.com/tristanisham/zvm";
  };
})
