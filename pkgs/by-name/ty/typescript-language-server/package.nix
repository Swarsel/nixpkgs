{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeWrapper,
  nix-update-script,
  nodejs,
  prefetch-yarn-deps,
  replaceVars,
  testers,
  typescript,
  yarn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "typescript-language-server";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "typescript-language-server";
    repo = "typescript-language-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9xK1maMfWowWlzAtmwoR3CVqQCkUf6i9uBWVsobBQPA=";
  };

  patches = [
    (replaceVars ./default-fallbackTsserverPath.diff {
      typescript = "${typescript}/lib/node_modules/typescript/lib/tsserver.js";
    })
  ];

  nativeBuildInputs = [
    fixup-yarn-lock
    makeWrapper
    nodejs
    prefetch-yarn-deps
    yarn
  ];

  buildPhase = ''
    runHook preBuild

    yarn --offline build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out/lib/node_modules/typescript-language-server"
    cp -r lib node_modules package.json "$out/lib/node_modules/typescript-language-server"

    makeWrapper "${nodejs}/bin/node" "$out/bin/typescript-language-server" \
      --add-flags "$out/lib/node_modules/typescript-language-server/lib/cli.mjs"

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror $offlineCache
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install
    patchShebangs node_modules

    runHook postConfigure
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-68aXoafE/wc1iS7HHwF7g/i8ZREoTj4bV/RL3XYc0Rs=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language Server Protocol implementation for TypeScript using tsserver";
    homepage = "https://github.com/typescript-language-server/typescript-language-server";
    changelog = "https://github.com/typescript-language-server/typescript-language-server/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ marcel ];
    mainProgram = "typescript-language-server";
  };
})
