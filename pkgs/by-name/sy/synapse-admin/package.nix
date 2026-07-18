{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  formats,
  nix-update-script,
  nodejs,
  yarn-berry,
  baseUrl ? null,
}:

let
  config = lib.optionalAttrs (baseUrl != null) { restrictBaseUrl = baseUrl; };
  configFormat = formats.json { };
  configFile = configFormat.generate "synapse-admin-config" config;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "synapse-admin";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "Awesome-Technologies";
    repo = "synapse-admin";
    tag = finalAttrs.version;
    hash = "sha256-rK1Tc1K3wx6/1J8TEw5Lb9g09gbt/1HoZdDrEFzxTQQ=";
  };

  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/Awesome-Technologies/synapse-admin/blob/master/package.json#L13
    ./yarn-4.14-support.patch
  ];

  postPatch = ''
    substituteInPlace vite.config.ts \
      --replace-fail "git describe --tags" "echo ${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    nodejs
    yarn-berry
  ];

  env = {
    NODE_ENV = "production";
  };

  buildPhase = ''
    runHook preBuild

    yarn install --immutable --immutable-cache
    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out
    cp ${configFile} $out/config.json

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$NIX_BUILD_TOP"
    yarn config set enableGlobalCache false
    yarn config set cacheFolder $yarnOfflineCache

    runHook postConfigure
  '';

  # we cannot use fetchYarnDeps because that doesn't support yarn 2/berry lockfiles
  yarnOfflineCache = stdenv.mkDerivation {
    inherit (finalAttrs) version src patches;
    pname = "yarn-deps";
    nativeBuildInputs = [ yarn-berry ];

    env = {
      NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      YARN_ENABLE_TELEMETRY = 0;
    };

    buildPhase = ''
      runHook preBuild

      mkdir -p $out
      yarn install --immutable --mode skip-build

      runHook postBuild
    '';

    configurePhase = ''
      runHook preConfigure

      export HOME="$NIX_BUILD_TOP"
      yarn config set enableGlobalCache false
      yarn config set cacheFolder $out
      yarn config set --json supportedArchitectures "$supportedArchitectures"

      runHook postConfigure
    '';

    dontInstall = true;
    outputHash = "sha256-IiViodAB1KAYsRRr8+zw3vrCbUYp7Mdtazi0Y6SEFNU=";
    outputHashMode = "recursive";

    supportedArchitectures = builtins.toJSON {
      cpu = [
        "arm"
        "arm64"
        "ia32"
        "x64"
      ];

      libc = [
        "glibc"
        "musl"
      ];

      os = [
        "darwin"
        "linux"
      ];
    };
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Admin UI for Synapse Homeservers";
    homepage = "https://github.com/Awesome-Technologies/synapse-admin";
    changelog = "https://github.com/Awesome-Technologies/synapse-admin/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mkg20001
      ma27
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
