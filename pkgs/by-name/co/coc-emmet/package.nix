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
  pname = "coc-emmet";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-emmet";
    tag = finalAttrs.version;
    hash = "sha256-0f9wSn7W+8Pxce7hbdfNpL33oykuVGNifNnSPPdhKb8=";
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
    hash = "sha256-8oo/XG9WxgKIbhfBWiGry+SZJdQIFe/T5i9S0hgjmp0=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Emmet extension for coc.nvim";
    homepage = "https://github.com/neoclide/coc-emmet";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
