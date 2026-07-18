{
  lib,
  stdenv,
  fetchFromGitHub,
  docker,
  docker-compose,
  fetchYarnDeps,
  fixup-yarn-lock,
  git,
  makeBinaryWrapper,
  nix-update-script,
  node-gyp,
  nodejs,
  python3,
  yarn,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "devcontainer";
  version = "0.87.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bTJoMQnjmiFzUuaz+dukZ5NP9RznCNvvjmkTTY/Frwc=";
  };

  nativeBuildInputs = [
    yarn
    fixup-yarn-lock
    python3
    makeBinaryWrapper
    nodejs
    node-gyp
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror ${finalAttrs.yarnOfflineCache}
    # Without this, yarn will try to download the dependencies
    fixup-yarn-lock yarn.lock

    # set nodedir to prevent node-gyp from downloading headers
    export npm_config_nodedir=${nodejs}

    yarn --offline --frozen-lockfile
    yarn --offline --frozen-lockfile compile-prod

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,libexec}
    cp -r dist $out/libexec
    cp devcontainer.js $out/libexec/devcontainer.js
    cp -r node_modules $out/libexec/node_modules
    cp -r $src/scripts $out/libexec/scripts

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper "${lib.getExe nodejs}" "$out/bin/devcontainer" \
      --add-flags "$out/libexec/devcontainer.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          docker
          docker-compose
        ]
      }
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-AgwXCWogxVDaeiv8dUBvbsLLxLDrkYqb0HPFORd3ieQ=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dev container CLI, run and manage your dev environments via a devcontainer.json";
    homepage = "https://containers.dev/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rucadi ];
    platforms = lib.platforms.unix;
    mainProgram = "devcontainer";
  };
})
