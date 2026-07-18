{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "postcss";
  version = "8.5.15";

  src = fetchFromGitHub {
    owner = "postcss";
    repo = "postcss";
    tag = finalAttrs.version;
    hash = "sha256-HNMGYdp6s1flnV71eUc1oH/lw9nARlCOZPs2kRDZ1qI=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  installPhase = ''
    runHook preInstall

    rm -rf node_modules
    pnpm install --production --offline --force
    mkdir -p $out/lib/node_modules/postcss
    mv ./* $out/lib/node_modules/postcss

    runHook postInstall
  '';

  dontBuild = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-lpp5YHemVI+LVO+g/OXvcEUGBhmfeSith9uhbnyT6Ac=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Transforming styles with JS plugins";
    homepage = "https://postcss.org/";
    changelog = "https://github.com/postcss/postcss/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
