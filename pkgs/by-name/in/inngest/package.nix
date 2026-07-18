{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  testers,
}:
let
  version = "1.36.0";
  websiteRev = "159c0ac611e85ec85ffe0a8c8bf2c4a0330bdb38";

  src = fetchFromGitHub {
    owner = "inngest";
    repo = "inngest";
    tag = "v${version}";
    hash = "sha256-KyH9Bj3n7RwARDcb3l5nerYGIIk2mgXPZWLhyNMm+f0=";
  };

  website = fetchFromGitHub {
    hash = "sha256-EkTIv8jgcqzurz2M7PC6Kfh6x2Zxu7UmIhpTjlj8o88=";
    owner = "inngest";
    repo = "website";
    rev = websiteRev;
  };

  ui = stdenv.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "inngest-ui";

    nativeBuildInputs = [
      nodejs
      pnpm_10
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild
      pnpm --filter dev-server-ui build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/dist
      cp -r ui/apps/dev-server-ui/dist/. $out/dist/
      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-bt/7cpN9EXf2CZFRAaybr7pgJyInV0fdUy7Rv/UcT/I=";
      pnpm = pnpm_10;
      sourceRoot = "${finalAttrs.src.name}/ui";
    };

    pnpmRoot = "ui";
  });
in
buildGoModule (finalAttrs: {
  inherit version src;
  pname = "inngest";
  vendorHash = null;
  env.CGO_ENABLED = 0;

  preBuild = ''
    cp -r ${ui}/dist/. ./pkg/devserver/static/
    cp -r ${website}/. ./internal/embeddocs/website/
  '';

  postInstall = ''
    mv $out/bin/cmd $out/bin/inngest
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/inngest/inngest/pkg/inngest/version.Version=${version}"
  ];

  subPackages = [ "cmd" ];

  passthru = {
    inherit ui website websiteRev;
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "CLI and dev server for Inngest durable workflows";
    homepage = "https://github.com/inngest/inngest";
    changelog = "https://github.com/inngest/inngest/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.sspl;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      albertchae
      kikos0
    ];

    platforms = lib.lists.remove "x86_64-darwin" lib.platforms.all;
    mainProgram = "inngest";
  };
})
