{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  pname = "hunk";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "modem-dev";
    repo = "hunk";
    tag = "v${version}";
    hash = "sha256-FlwCtcu2JRECyKC1balItY/DmQyb+obh+97wo7+06DU=";
  };

  node_modules = stdenv.mkDerivation {
    inherit version src;
    pname = "${pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out
      find packages -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontConfigure = true;
    dontFixup = true;
    outputHash = "sha256-LkOAWScuNPx9/KOcG110ngLz0QmB4/S3VxIAb3EIH7I=";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  strictDeps = true;

  nativeBuildInputs = [
    bun
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p .bun-tmp .bun-install
    BUN_TMPDIR=$PWD/.bun-tmp \
    BUN_INSTALL=$PWD/.bun-install \
      bun build --compile \
        --no-compile-autoload-bunfig \
        --no-compile-autoload-dotenv \
        src/main.tsx \
        --outfile hunk

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 hunk $out/bin/hunk
    mkdir -p $out/share/hunk
    cp -R skills $out/share/hunk/skills
    ln -s share/hunk/skills $out/skills

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/hunk --version | grep -F ${version}
    test -f "$($out/bin/hunk skill path)"

    runHook postInstallCheck
  '';

  __structuredAttrs = true;

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/. .
    chmod -R u+w node_modules
    find packages -type d -name node_modules -exec chmod -R u+w {} \;

    runHook postConfigure
  '';

  dontFixup = true;
  dontStrip = true;
  versionCheckProgramArg = "--version";

  passthru = {
    inherit node_modules;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "node_modules"
      ];
    };
  };

  meta = {
    description = "Terminal diff viewer for agentic changesets";
    homepage = "https://github.com/modem-dev/hunk";
    changelog = "https://github.com/modem-dev/hunk/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];

    maintainers = with lib.maintainers; [
      MarkusZoppelt
      kaynetik
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "hunk";
  };
}
