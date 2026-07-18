{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  clang_20,
  libsecret,
  nodejs,
  pkg-config,
  python3,
  rsync,
  xcbuild,
  yarn-berry_4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "joplin-cli";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "laurent22";
    repo = "joplin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nWMUvAseKoTOv5ui9uYDUiGlvO+8nNV4ux7JbsnrM5U=";

    postFetch = ''
      # there's a file with a weird name that causes a hash mismatch on darwin
      rm $out/packages/app-cli/tests/support/photo*
    '';
  };

  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/laurent22/joplin/blob/dev/package.json#L103
    ./yarn-4.14-support.patch
  ];

  postPatch = ''
    # Don't immediately build everything
    sed -i '/postinstall/d' package.json
    # Don't install onenote-converter subpackage deps
    sed -i '/onenote-converter/d' packages/{lib,app-cli}/package.json
  '';

  nativeBuildInputs = [
    nodejs
    yarn-berry_4.yarn-berry-offline
    yarn-berry_4.yarnBerryConfigHook
    (python3.withPackages (ps: with ps; [ distutils ]))
    pkg-config
    libsecret
    rsync
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild
    buildPackages.cctools
    clang_20 # clang_21 breaks keytar, sqlite
  ];

  buildInputs = [
    nodejs
  ];

  env = {
    # Disable scripts so that yarn doesn't immediately run them
    # We want to patch them first
    YARN_ENABLE_SCRIPTS = 0;
  };

  buildPhase = ''
    runHook preBuild

    unset YARN_ENABLE_SCRIPTS

    yarn config set enableInlineBuilds true

    for node_modules in packages/*/node_modules; do
      patchShebangs $node_modules
    done

    yarn workspaces focus root joplin
    yarn workspaces foreach -Rptvi --from joplin run tsc
    yarn workspaces foreach -Rtvi --from joplin run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Remove dev dependencies
    yarn workspaces focus --production root joplin

    mkdir -p $out/lib/packages
    mkdir $out/bin
    mv packages/{app-cli,renderer,tools,utils,lib,htmlpack,turndown{,-plugin-gfm},fork-*} $out/lib/packages/
    rm -rf $out/lib/packages/lib/node_modules/canvas

    # Remove extra files
    rm -rf $out/lib/packages/app-cli/{app/*.test.ts,*.md,.*ignore,tests/,tools/,*.js,*.json,*.sh}

    # Link final binary
    chmod +x $out/lib/packages/app-cli/app/main.js
    ln -s $out/lib/packages/app-cli/app/main.js $out/bin/joplin
    patchShebangs $out/bin/joplin

    runHook postInstall
  '';

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry_4.fetchYarnBerryDeps {
    inherit (finalAttrs)
      src
      missingHashes
      patches
      postPatch
      ;

    hash = "sha256-mdDVYLJ4ZN7zJJdf/2Wh+or+p1uJPTrMCyDYWwc04YM=";
  };

  updateScript = ./update.sh;

  meta = {
    description = "CLI client for Joplin";
    homepage = "https://joplinapp.org/";
    changelog = "https://github.com/laurent22/joplin/releases/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "joplin";
  };
})
