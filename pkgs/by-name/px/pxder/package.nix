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
  pname = "pxder";
  version = "2.12.8";

  src = fetchFromGitHub {
    owner = "Tsuk1ko";
    repo = "pxder";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+WZbs10+id+nohTZzLjEofb6k8PMGd73YhY3FUTXx5Q=";
  };

  nativeBuildInputs = [
    makeWrapper
    fixup-yarn-lock
    yarn
  ];

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out/lib/node_modules/pxder"
    cp -r . "$out/lib/node_modules/pxder"

    makeWrapper "${nodejs}/bin/node" "$out/bin/pxder" \
      --add-flags "$out/lib/node_modules/pxder/bin/pxder"

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$offlineCache"
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install

    runHook postConfigure
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-++MqWIUntXQwOYpgAJ3nhAtZ5nxmEreioVHQokYkw7w=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = {
    description = "Download illusts from pixiv.net";
    homepage = "https://github.com/Tsuk1ko/pxder";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vanilla ];
    platforms = lib.platforms.all;
    mainProgram = "pxder";
  };
})
