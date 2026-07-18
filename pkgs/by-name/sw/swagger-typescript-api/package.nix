{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeBinaryWrapper,
  nodejs,
  writableTmpDirAsHomeHook,
}:
let
  pname = "swagger-typescript-api";
  version = "13.9.3";

  node-modules-hash = {
    "aarch64-linux" = "sha256-7hR5cS8fFN1Eb82eKF+B24FdznfQn5roRqGe9dHk5H4=";
    "x86_64-linux" = "sha256-0jTq1Ds8CNDGOaXZlBgtl5IspoLTGzfXwOhR9MwhoYQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "acacode";
    repo = "swagger-typescript-api";
    rev = "v${version}";
    hash = "sha256-Xy67aqkZAB54dz9yabJHvOLilb2C/oe8ZCprnqfBBj4=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs
    bun
  ];

  buildPhase = ''
    runHook preBuild

    cp -R ${finalAttrs.node_modules}/node_modules .
    patchShebangs node_modules

    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r {dist,templates,node_modules} $out/lib

    makeBinaryWrapper ${nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/dist/cli.cjs \
      --set NODE_ENV production \
      --set NODE_PATH "$out/lib/node_modules"

    runHook postInstall
  '';

  node_modules = stdenv.mkDerivation {
    inherit (finalAttrs) src version;
    pname = "${pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install --no-progress --frozen-lockfile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';

    dontConfigure = true;
    # Skip fixup, would embed store paths or modify binaries,
    # making this fixed-output derivation's output hash unstable.
    dontFixup = true;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    outputHash =
      node-modules-hash.${stdenv.hostPlatform.system}
        or (throw "${finalAttrs.pname}: Platform ${stdenv.hostPlatform.system} is not packaged yet. Supported platforms: x86_64-linux, aarch64-linux.");

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  meta = {
    description = "Generate TypeScript API client and definitions for fetch or axios from an OpenAPI specification";
    homepage = "https://github.com/acacode/swagger-typescript-api";
    changelog = "https://github.com/acacode/swagger-typescript-api/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ angelodlfrtr ];
    platforms = lib.platforms.linux;
    mainProgram = "swagger-typescript-api";
  };
})
