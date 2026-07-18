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
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ctx7";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "${finalAttrs.pname}@${finalAttrs.version}";
    hash = "sha256-yyz4UraRm1JR/C7J2ib0nBU6zsNpKCWIWduTu7OlebM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter ${finalAttrs.pname} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm \
      --filter ${finalAttrs.pname} \
      --offline \
      --config.inject-workspace-packages=true \
      --config.shamefully-hoist=true \
      deploy $out/lib/ctx7

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/ctx7 \
      --add-flags "$out/lib/ctx7/dist/index.js"

    cp -R $src/{plugins,rules,skills} $out

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-S+TCwe4FJHjSLTUL/cPh+eRtWx/z7REUyfMNT0BgK7k=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "${finalAttrs.pname}@(.*)"
    ];
  };

  meta = {
    description = "Context7 CLI - Manage AI coding skills and documentation context";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.unix;
    mainProgram = "ctx7";
  };
})
