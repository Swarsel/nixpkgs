{
  lib,
  fetchFromGitHub,
  buildGoModule,
  esbuild,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
let
  esbuild' =
    let
      version = "0.16.17";
    in
    esbuild.override {
      buildGoModule =
        args:
        buildGoModule (
          args
          // {
            inherit version;

            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-8L8h0FaexNsb3Mj6/ohA37nYLFogo5wXkAhGztGUUsQ=";
            };

            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          }
        );
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coc-sqlfluff";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "yaegassy";
    repo = "coc-sqlfluff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hTe0rtjIKdlPSvwcHI2m0sRkVfmW8eQ/63WLmPsiovI=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    esbuild'
  ];

  env.ESBUILD_BINARY_PATH = lib.getExe esbuild';

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-Pz7OCAiPIMVCAYe9OGWKMLfGSwK8ulA/JW55eB8xJqw=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SQLFluff extension for coc.nvim";
    homepage = "https://github.com/yaegassy/coc-sqlfluff";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
