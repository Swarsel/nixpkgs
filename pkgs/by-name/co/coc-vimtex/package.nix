{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coc-vimtex";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-vimtex";
    tag = finalAttrs.version;
    hash = "sha256-Z0vhgpdzh3GY9o6qnYWkeaUtjtoJ6PdqtDpRQHQXCjI=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-XEDPfnEkUTVCpxBp/DAdrRDvxYrTo/e+PTQGmtSy58c=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VimTeX extension for coc.nvim";
    homepage = "https://github.com/neoclide/coc-vimtex";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
