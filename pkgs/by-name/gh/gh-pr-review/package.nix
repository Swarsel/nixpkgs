{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-review";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "agynio";
    repo = "gh-pr-review";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NVctUkxfYGs29T9naAfqbEhUXfhynx8Ajsh+V+4gCLw=";
  };

  nativeBuildInputs = lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    installShellFiles
  ];

  vendorHash = "sha256-CEV23koYz0FpSWXJRF4J+dGNuDT8Ftkn4LGFftvd0ts=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gh-pr-review \
      --zsh <($out/bin/gh-pr-review completion zsh) \
      --fish <($out/bin/gh-pr-review completion fish) \
      --bash <($out/bin/gh-pr-review completion bash)
  '';

  __structuredAttrs = true;

  meta = {
    description = "GitHub CLI extension that adds full inline PR review comment support";
    homepage = "https://github.com/agynio/gh-pr-review";
    changelog = "https://github.com/agynio/gh-pr-review/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "gh-pr-review";
  };
})
