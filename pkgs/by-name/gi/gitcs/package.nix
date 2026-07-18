{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gitcs";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "hrtsegv";
    repo = "gitcs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mRQfW0sY6la8SyO+zDr/HcakDugRShW/Aea9uj6G/gA=";
  };

  vendorHash = "sha256-bG0BaH8yYp8TUiK/7xvghB4T48LcBEvmF1uvY5eYkww=";
  env.CGO_ENABLED = 0;

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    git config --global init.defaultBranch main
    bash ./setup-test.sh
  '';

  ldflags = [ "-s" ];

  meta = {
    description = "Scan local git repositories and generate a visual contributions graph";
    homepage = "https://github.com/hrtsegv/gitcs";
    changelog = "https://github.com/hrtsegv/gitcs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "gitcs";
  };
})
