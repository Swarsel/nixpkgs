{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeWrapper,
  nodejs,
  yarn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "node-hp-scan-to";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "manuc66";
    repo = "node-hp-scan-to";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/XUqCL2F1iMYUoCbGgL9YKs+8wIFHvmh2O0LMbDU8yE=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    fixup-yarn-lock
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

    mkdir -p "$out/lib/node_modules/node-hp-scan-to"
    cp -r dist node_modules package.json "$out/lib/node_modules/node-hp-scan-to"

    makeWrapper "${nodejs}/bin/node" "$out/bin/node-hp-scan-to" \
      --add-flags "$out/lib/node_modules/node-hp-scan-to/dist/index.js"

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
    hash = "sha256-pxeYumHuomOFyCi8XhYTYQNcsGOUvjOg36bFD0yhdLk=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = {
    description = "Allow to send scan from device to computer for some HP All-in-One Printers";
    homepage = "https://github.com/manuc66/node-hp-scan-to";
    changelog = "https://github.com/manuc66/node-hp-scan-to/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jonas-w ];
    mainProgram = "node-hp-scan-to";
  };
})
