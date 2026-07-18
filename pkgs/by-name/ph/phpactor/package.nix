{
  lib,
  fetchFromGitHub,
  installShellFiles,
  php,
  versionCheckHook,
}:
php.buildComposerProject2 (finalAttrs: {
  pname = "phpactor";
  version = "2026.06.25.0";

  src = fetchFromGitHub {
    owner = "phpactor";
    repo = "phpactor";
    tag = finalAttrs.version;
    hash = "sha256-3KnD/ME5UXHfeFrpJBlHssQgZ3GZuc6P2EbiGToZK1k=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-k6Mus33SVpKJ//oAlbZFNHh+t+f7rQiryOxlkzyhV8s=";

  postInstall = ''
    installShellCompletion --cmd phpactor \
    --bash <(php $out/bin/phpactor completion bash)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Mainly a PHP Language Server";
    homepage = "https://github.com/phpactor/phpactor";
    changelog = "https://github.com/phpactor/phpactor/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    mainProgram = "phpactor";
  };
})
