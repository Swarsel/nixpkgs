{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tldx";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "brandonyoungdev";
    repo = "tldx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3eVVN5PP3MxMSlZK+cASw7twgUZryMdTNOuseoynSZI=";
  };

  vendorHash = "sha256-ApR/XDuOpXiZuyJWEsMbrwYn81Rq9XAYh38fbPoh7rM=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/brandonyoungdev/tldx/cmd.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Domain availability research tool";
    homepage = "https://github.com/brandonyoungdev/tldx";
    changelog = "https://github.com/brandonyoungdev/tldx/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sylonin ];
    mainProgram = "tldx";
  };
})
