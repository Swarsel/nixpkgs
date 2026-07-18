{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "git-ls";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "llimllib";
    repo = "git-ls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g+LFQEud4nF+3hRaH8JcjQHx6Ol2LDRRP2HdQ2oLfls=";
  };

  strictDeps = true;
  vendorHash = "sha256-Bk6IBG+BrqY4FNVIlbSSSnqqAeL+8SJUtRXuIp4e8f8=";

  nativeCheckInputs = [
    gitMinimal
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  ldflags = [ "-s" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "List files and git status in a repository";
    homepage = "https://github.com/llimllib/git-ls";
    changelog = "https://github.com/llimllib/git-ls/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "git-ls";
  };
})
