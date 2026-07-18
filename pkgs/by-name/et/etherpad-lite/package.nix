{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "etherpad-lite";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "ether";
    repo = "etherpad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8DCgbfp3ttpMTXS9SNkN1R63LZHaklsNHViRhmWVFuk=";
  };

  patches = [
    ./outdir.patch
    # etherpad expects to read and write $out/lib/var/installed_plugins.json
    # FIXME: this patch disables plugin support
    ./dont-fail-on-plugins-json.patch
  ];

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_9
    makeWrapper
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    NODE_ENV="production" pnpm run build:etherpad
    runHook postBuild
  '';

  preInstall = ''
    # remove unnecessary files
    rm node_modules/.modules.yaml
    CI=true pnpm prune --prod --ignore-scripts
    find -type f \( -name "*.d.ts" -o -name "*.map" \) -exec rm -rf {} +

    # remove non-deterministic files
    rm node_modules/.modules.yaml
  '';

  # Upstream scripts uses `pnpm run prod` which is equivalent to
  # `cross-env NODE_ENV=production node --require tsx/cjs node/server.ts`
  installPhase = ''
    runHook preInstall
    mkdir -p $out/{lib/etherpad-lite,bin}
    cp -r node_modules ui src doc admin $out/lib/etherpad-lite
    makeWrapper ${lib.getExe nodejs} $out/bin/etherpad-lite \
      --inherit-argv0 \
      --add-flags "--require tsx/cjs $out/lib/etherpad-lite/node_modules/ep_etherpad-lite/node/server.ts" \
      --suffix PATH : "${lib.makeBinPath [ pnpm_9 ]}" \
      --set NODE_PATH "$out/lib/node_modules:$out/lib/etherpad-lite/node_modules/ep_etherpad-lite/node_modules" \
      --set-default NODE_ENV production
    find $out/lib -xtype l -delete
    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-2nKpmGxC+KVg0oF0BsswS9L84QxzpRF7NvKyqyQ7WJM=";
    pnpm = pnpm_9;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern really-real-time collaborative document editor";

    longDescription = ''
      Etherpad is a real-time collaborative editor scalable to thousands of simultaneous real time users.
      It provides full data export capabilities, and runs on your server, under your control.
    '';

    homepage = "https://etherpad.org/";
    changelog = "https://github.com/ether/etherpad/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      erdnaxe
      f2k1de
    ];

    platforms = lib.platforms.unix;
    mainProgram = "etherpad-lite";
  };
})
