{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  versionCheckHook,
}:
let
  tag-prefix = "@upstash/context7-mcp";

  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "context7-mcp";
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "${tag-prefix}@${finalAttrs.version}";
    hash = "sha256-yyz4UraRm1JR/C7J2ib0nBU6zsNpKCWIWduTu7OlebM=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter ${tag-prefix} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm --filter ${tag-prefix} \
         --offline \
         --config.inject-workspace-packages=true \
         deploy $out/lib/context7

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/context7-mcp \
      --add-flags "$out/lib/context7/dist/index.js"

    cp -r $src/skills $out

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-S+TCwe4FJHjSLTUL/cPh+eRtWx/z7REUyfMNT0BgK7k=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "${tag-prefix}@(.*)"
    ];
  };

  meta = {
    description = "MCP Server for up-to-date code documentation for LLMs and AI code editors";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "context7-mcp";
  };
})
