{
  lib,
  fetchFromGitHub,
  bun,
  nix-update-script,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
}:
let
  pname = "models-dev";
  version = "sdk-v0.0.5-unstable-2026-07-07";
  src = fetchFromGitHub {
    owner = "anomalyco";
    repo = "models.dev";
    rev = "f1a9be19f62c24474d27947d5236067504dd755a";
    hash = "sha256-ty8l1jURV2uf245Xqm+I95qZ8gU9IjTGqR7+yLGxBUs=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    inherit version src;
    pname = "${pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontConfigure = true;
    # NOTE: Required else we get errors that our fixed-output derivation references store paths
    dontFixup = true;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    outputHash = "sha256-aL2kNCYF6Y4QnEvlpQ9U5Qe+K8a1J2X7BvJqE+BnRcY=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    src
    node_modules
    ;

  nativeBuildInputs = [ bun ];

  buildPhase = ''
    runHook preBuild

    cd packages/web
    bun run ./script/build.ts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/dist
    cp -R ./dist $out

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/. .

    runHook postConfigure
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--subpackage"
      "node_modules"
    ];
  };

  meta = {
    description = "Comprehensive open-source database of AI model specifications, pricing, and capabilities";
    homepage = "https://github.com/anomalyco/models.dev";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ delafthi ];
    platforms = lib.platforms.unix;
  };
})
