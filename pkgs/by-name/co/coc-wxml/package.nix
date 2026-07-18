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
  pname = "coc-wxml";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc-wxml";
    tag = finalAttrs.version;
    hash = "sha256-6tI+rIgoKGafBSxbPumCquAahJVR3rUzJB4VWQR+qw0=";
  };

  # Fix yarn.lock file
  postPatch = ''
    substituteInPlace yarn.lock \
      --replace-fail "http://registry.npmjs.org" "https://registry.yarnpkg.com"
  '';

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src postPatch;
    hash = "sha256-s2doN+DeVJPIWe/vOuAH7cYl/S/v8S4yeTG6KIWKphA=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wxml extension for coc.nvim";
    homepage = "https://github.com/neoclide/coc-wxml";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
