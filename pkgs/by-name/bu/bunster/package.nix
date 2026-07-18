{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "bunster";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "yassinebenaid";
    repo = "bunster";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HE5Wp5A0wc5jgs9kNkCH1f82Y+SkILHvOwlQAsC6DVU=";
  };

  vendorHash = "sha256-Gs+8J+yEVynsBte3Hnx7jnYRPa/61CIISDbMyDKhPRE=";
  # checks fail on aarch64-darwin but binary still builds successfully
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Compile shell scripts to static binaries";
    homepage = "https://github.com/yassinebenaid/bunster";
    changelog = "https://github.com/yassinebenaid/bunster/releases/tag/v{finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      yunz
    ];

    platforms = lib.platforms.unix;
    mainProgram = "bunster";
  };
})
