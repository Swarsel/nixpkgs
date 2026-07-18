{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  ffmpeg,
  makeWrapper,
  nix-update-script,
  nixosTests,
  node-gyp,
  nodejs_24,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  prisma-engines_6,
  python3,
  versionCheckHook,
  vips,
}:

let
  environment = {
    FFMPEG_PATH = lib.getExe ffmpeg;
    FFPROBE_PATH = lib.getExe' ffmpeg "ffprobe";
    NEXT_TELEMETRY_DISABLED = "1";
    PRISMA_FMT_BINARY = lib.getExe' prisma-engines_6 "prisma-fmt";
    PRISMA_INTROSPECTION_ENGINE_BINARY = lib.getExe' prisma-engines_6 "introspection-engine";
    PRISMA_QUERY_ENGINE_BINARY = lib.getExe' prisma-engines_6 "query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines_6}/lib/libquery_engine.node";
    PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe' prisma-engines_6 "schema-engine";
  };

  pnpm' = pnpm_10.override { nodejs-slim = nodejs_24; };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "zipline";
  version = "4.6.4";

  src = fetchFromGitHub {
    owner = "diced";
    repo = "zipline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-feGsg481S+LShOIE0JMHsCkIShQk+cYvfQUYupQnJp0=";
    leaveDotGit = true;

    postFetch = ''
      git -C $out rev-parse --short HEAD > $out/.git_head
      rm -rf $out/.git
    '';
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm'
    nodejs_24
    makeWrapper
    # for sharp build:
    node-gyp
    pkg-config
    python3
  ];

  buildInputs = [
    openssl
    vips
  ];

  env = environment // {
    DATABASE_URL = "dummy";
    NODE_PATH = "${node-gyp}/lib/node_modules";
  };

  buildPhase = ''
    runHook preBuild

    # Force build of sharp against native libvips (requires running install scripts).
    # This is necessary for supporting old CPUs (ie. without SSE 4.2 instruction set).
    pnpm config set nodedir ${nodejs_24}
    npm explore sharp -- pnpm run build

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    CI=true pnpm prune --prod
    find node_modules -xtype l -delete

    mkdir -p $out/{bin,share/zipline}

    cp -r build node_modules prisma mimes.json code.json package.json $out/share/zipline

    mkBin() {
      makeWrapper ${lib.getExe nodejs_24} "$out/bin/$1" \
        --chdir "$out/share/zipline" \
        --set NODE_ENV production \
        --set ZIPLINE_GIT_SHA "$(<$src/.git_head)" \
        --prefix PATH : ${lib.makeBinPath [ openssl ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ openssl ]} \
        ${
          lib.concatStringsSep " " (
            lib.mapAttrsToList (name: value: "--set ${name} ${lib.escapeShellArg value}") environment
          )
        } \
        --add-flags "--enable-source-maps build/$2"
    }

    mkBin zipline server
    mkBin ziplinectl ctl

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-iaC3jJ2+oLY3ycTBE01HzrDhBN9MpvgDFOyjzy2LLAo=";
    pnpm = pnpm';
  };

  versionCheckKeepEnvironment = [ "DATABASE_URL" ];
  versionCheckProgram = "${placeholder "out"}/bin/ziplinectl";

  passthru = {
    prisma-engines = prisma-engines_6;
    tests = { inherit (nixosTests) zipline; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "ShareX/file upload server that is easy to use, packed with features, and with an easy setup";
    homepage = "https://zipline.diced.sh/";
    changelog = "https://github.com/diced/zipline/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    platforms = lib.platforms.linux;
    mainProgram = "zipline";
    downloadPage = "https://github.com/diced/zipline";
  };
})
