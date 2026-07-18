{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  shadcn,
  stdenvNoCC,
  testers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shadcn";
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "shadcn-ui";
    repo = "ui";
    rev = "shadcn@${finalAttrs.version}";
    hash = "sha256-jwZBYQKixm3YAC8uLSeQMwTFoOrw4EgkvgC1FWShxy0=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run shadcn:build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r {packages,node_modules} $out/lib

    # cleanup
    find $out/lib/packages/shadcn -name '*.ts' -delete

    makeWrapper ${lib.getExe nodejs} $out/bin/shadcn \
      --inherit-argv0 \
      --add-flags $out/lib/packages/shadcn/dist/index.js

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;

    fetcherVersion = 4;
    hash = "sha256-XqdSa9ONpJ/QOu7njPMhG0xyTLEN9nt/dm3E0ivDaEs=";
    pnpm = pnpm_10;
  };

  pnpmWorkspaces = [ "shadcn" ];

  passthru.tests.version = testers.testVersion {
    version = finalAttrs.version;
    command = "shadcn --version";
    package = shadcn;
  };

  meta = {
    description = "Beautifully designed components that you can copy and paste into your apps";
    homepage = "https://ui.shadcn.com/docs/cli";

    changelog = "https://github.com/shadcn-ui/ui/blob/${finalAttrs.src.rev}/packages/shadcn/CHANGELOG.md#${
      builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }";

    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getpsyched ];
    platforms = lib.platforms.all;
    mainProgram = "shadcn";
  };
})
