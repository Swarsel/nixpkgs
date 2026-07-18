{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "opkssh";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "openpubkey";
    repo = "opkssh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-COACiBNXHEpzZyGGYmz0uj0ubzYJFRabAEku2qOjLcg=";
  };

  vendorHash = "sha256-aRWu4yB83hBKtW78MVMg7l8iSzHdLgnYgskgt32tiLw=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [ "-X main.Version=${finalAttrs.version}" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Enables SSH to be used with OpenID Connect";
    homepage = "https://github.com/openpubkey/opkssh";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      johnrichardrinehart
      sarcasticadmin
    ];

    mainProgram = "opkssh";
  };
})
