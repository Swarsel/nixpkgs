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
  pname = "coc-html";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-html";
    tag = finalAttrs.version;
    hash = "sha256-dMjkG/djycRhRPIMCQ1PYvfXVxlWHtcNjouW+bCm59I=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-hb8H7tI4OouLBTwuSx3UVw7I52HTYxOFkAVJGaIKHzI=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Html language server extension for coc.nvim";
    homepage = "https://github.com/neoclide/coc-html";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
