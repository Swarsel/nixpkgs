{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  jq,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nodejs-slim_24,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "turborepo-remote-cache";
  version = "2.11.2";

  src = fetchFromGitHub {
    owner = "ducktors";
    repo = "turborepo-remote-cache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V56EEG5iO8lKXRfk5UUo5so58xCEZavYfT1Bj6QYfA8=";
  };

  postPatch = ''
    # Replace build script to skip linting
    jq '.scripts.build = "tsc -p ./tsconfig.json"' package.json > package.json.tmp
    mv package.json.tmp package.json

    # Remove prepare script since we don't need git hooks
    jq 'del(.scripts.prepare)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  nativeBuildInputs = [
    nodejs-slim_24
    pnpmConfigHook
    pnpm_10
    jq
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    pnpm prune --prod
    # Clean up broken symlinks left behind by `pnpm prune`
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete
     # Remove non-deterministic files
    rm node_modules/.modules.yaml
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appdir="$out/lib/turborepo-remote-cache"
    mkdir -p "$appdir" "$out/bin"

    cp -r dist node_modules "$appdir"/

    makeWrapper ${nodejs-slim_24}/bin/node "$out/bin/turborepo-remote-cache" \
      --add-flags "$appdir/dist/index.js" \
      --set NODE_PATH "$appdir/node_modules"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-dMil3ZlCVDOp7q0IxmDQgyBqqsvwidizy3z9b3Bq0hE=";
    pnpm = pnpm_10;
  };

  passthru = {
    tests = { inherit (nixosTests) turborepo-remote-cache; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "This project is an open-source implementation of the Turborepo custom remote cache server.";
    homepage = "https://github.com/ducktors/turborepo-remote-cache";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      humemm
      ibizaman
    ];

    mainProgram = "turborepo-remote-cache";
  };
})
