{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coc-r-lsp";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-r-lsp";
    tag = finalAttrs.version;
    hash = "sha256-pjxnNzWOqlVWNNvEF9Yx1aQa4i3BpJoenuGQmY/k1QA=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-BUg1ZhJn3pF2cQB6b1Fe0jsd9gi2ZyMhCt7SXtjvY54=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "R LSP client for coc.nvim";
    homepage = "https://github.com/neoclide/coc-r-lsp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
