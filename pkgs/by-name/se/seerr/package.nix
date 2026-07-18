{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nodejs-slim_22,
  pnpmConfigHook,
  pnpm_10,
  python3,
  python3Packages,
  sqlite,
}:

let
  nodejs-slim = nodejs-slim_22;
  pnpm = pnpm_10.override { inherit nodejs-slim; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "seerr";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "seerr-team";
    repo = "seerr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L3gIpkxWIPvAz2o4gDS41w4GyCEfdVVrIQE6hNBLz90=";
  };

  nativeBuildInputs = [
    python3
    python3Packages.distutils
    nodejs-slim
    makeWrapper
    pnpmConfigHook
    pnpm
  ];

  buildInputs = [ sqlite ];

  preBuild = ''
    export npm_config_nodedir=${nodejs-slim}
    pushd node_modules
    pnpm rebuild bcrypt sqlite3
    popd
  '';

  buildPhase = ''
    runHook preBuild

    pnpm build
    CI=true pnpm prune --prod --ignore-scripts
    rm -rf .next/cache

    # Clean up broken symlinks left behind by `pnpm prune`
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r -t $out/share .next node_modules dist public package.json seerr-api.yml
    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper '${nodejs-slim}/bin/node' "$out/bin/seerr" \
      --add-flags "$out/share/dist/index.js" \
      --chdir "$out/share" \
      --set NODE_ENV production
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-WFbTBk2U0KS65LauKcqtD+y6RlcIMnN4tUWYM2WOUnQ=";
  };

  passthru = {
    inherit (nixosTests) seerr;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open-source media request and discovery manager for Jellyfin, Plex, and Emby";
    homepage = "https://github.com/seerr-team/seerr";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      camillemndn
      fallenbagel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "seerr";
  };
})
