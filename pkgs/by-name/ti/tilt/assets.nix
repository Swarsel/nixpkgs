{
  lib,
  cacert,
  nodejs,
  src,
  stdenvNoCC,
  version,
  yarn-berry,
}:

let
  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/tilt-dev/tilt/blob/master/web/package.json#L94
    ./yarn-4.14-support.patch
  ];
in
stdenvNoCC.mkDerivation {
  inherit version patches;
  pname = "tilt-assets";
  src = "${src}/web";

  nativeBuildInputs = [
    nodejs
    yarn-berry
  ];

  buildPhase = ''
    runHook preBuild

    yarn install --immutable --immutable-cache
    yarn build

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out
    cp -r build/. $out/
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$NIX_BUILD_TOP"
    export YARN_ENABLE_TELEMETRY=0

    yarn config set enableGlobalCache false
    yarn config set cacheFolder $yarnOfflineCache

    runHook postConfigure
  '';

  yarnOfflineCache = stdenvNoCC.mkDerivation {
    inherit patches;
    src = "${src}/web";
    nativeBuildInputs = [ yarn-berry ];

    buildPhase = ''
      runHook preBuild

      mkdir -p $out
      yarn install --immutable --mode skip-build

      runHook postBuild
    '';

    NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    configurePhase = ''
      runHook preConfigure

      export HOME="$NIX_BUILD_TOP"
      export YARN_ENABLE_TELEMETRY=0

      yarn config set enableGlobalCache false
      yarn config set cacheFolder $out
      yarn config set supportedArchitectures --json "$supportedArchitectures"

      runHook postConfigure
    '';

    dontInstall = true;
    name = "tilt-assets-deps";
    outputHash = "sha256-3P42xJ1tBVRpe1hNDy4ax9bUmiaPnSZolTGmsKpzYUA=";
    outputHashAlgo = "sha256";
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

  meta = {
    description = "Assets needed for Tilt";
    homepage = "https://tilt.dev/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anton-dessiatov ];
    platforms = lib.platforms.all;
  };
}
