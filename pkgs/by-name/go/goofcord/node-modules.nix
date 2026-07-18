# fixed output derivation for node_modules
{
  lib,
  stdenv,
  bun,
  goofcord,
  nodejs,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation {
  inherit (goofcord) version src;
  pname = goofcord.pname + "-modules";

  nativeBuildInputs = [
    bun
    nodejs
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild

    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
    export npm_config_build_from_source=true
    export ELECTRON_SKIP_BINARY_DOWNLOAD=1

    bun install \
      --frozen-lockfile \
      --linker=hoisted \
      --no-progress

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -R ./node_modules $out

    runHook postInstall
  '';

  dontConfigure = true;
  dontFixup = true;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"
  ];

  outputHash =
    {
      aarch64-linux = "sha256-RGJGUdp3i6Q/tCuQ42NfF4eFGrrgoyhx1l14fPwlCN8=";
      x86_64-linux = "sha256-2PH4qa4M/y4AzVT9dW4BK1jE3RWSr+NWY1AhU3cfUTE=";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system ${stdenv.hostPlatform.system}");

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  meta = {
    description = "Node modules for GoofCord";
    license = lib.licenses.osl3;
    platforms = lib.platforms.linux;
  };
}
