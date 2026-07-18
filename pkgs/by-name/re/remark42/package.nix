{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  nodejs-slim_22,
  pnpmConfigHook,
  pnpm_9,
  testers,
}:

let
  pnpm = pnpm_9.override { nodejs-slim = nodejs-slim_22; };
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "remark42";
    tag = "v${version}";
    hash = "sha256-yd/qTRSZj0nZpgK77xP+XHyHcVXlNpyMzdfj6EbVcXQ=";
  };

  remark42-web = stdenv.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "remark42-web";

    postPatch = ''
      substituteInPlace "package.json" "apps/remark42/package.json" \
        --replace-fail "pnpm@8.15.9" "pnpm@${pnpm.version}"

      substituteInPlace "apps/remark42/package.json" \
        --replace-fail '"pnpm": "8.*"' '"pnpm": "9.*"'
    '';

    strictDeps = true;

    nativeBuildInputs = [
      nodejs-slim_22
      pnpm
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      pnpm --filter ./apps/remark42 --fail-if-no-match run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/web
      cp -r "apps/remark42/public/." $out/web/

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        postPatch
        ;

      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-wFrMoSeD87H1yfMD0jBcw60DKDeh4yjka5aWyHuQssA=";
    };

    sourceRoot = "${src.name}/frontend";
  });
in
buildGoModule (finalAttrs: {
  inherit version src;
  pname = "remark42";
  strictDeps = true;
  vendorHash = null;

  preBuild = ''
    rm -rf app/cmd/web
    mkdir -p app/cmd/web
    cp -r ${remark42-web}/web/. app/cmd/web/
  '';

  postInstall = ''
    mv "$out/bin/app" "$out/bin/remark42"
  '';

  # set the version string in the built binary.
  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.revision=v${version}"
  ];

  modRoot = "backend";
  # build the main package in ./backend/app
  subPackages = [ "app" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "remark42 --help";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Self-hosted comment engine that embeds a statically built frontend";
    homepage = "https://remark42.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ janhencic ];
    platforms = lib.platforms.unix;
    mainProgram = "remark42";
  };
})
