{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  curl,
  makeWrapper,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kulala-core";
  version = "0.28.1";

  src = fetchFromGitHub {
    owner = "mistweaverco";
    repo = "kulala-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8NG9Qw7hJwiMb2iU8WbtEGVv1+Z3P0dQR3b1Nrwwn80=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    cp -R ${finalAttrs.node_modules}/node_modules .
    echo '{ "version": "${finalAttrs.version}" }' > packages/core/version.json
    (
      cd packages/core
      bun build src/cli.ts \
        --target=bun \
        --outdir=dist \
        --asset-naming='[name].[ext]'
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 packages/core/dist/cli.js $out/lib/kulala-core/kulala-core.js
    install -Dm644 packages/core/dist/liblua5.1.wasm $out/lib/kulala-core/liblua5.1.wasm
    makeWrapper ${lib.getExe bun} $out/bin/kulala-core \
      --add-flags $out/lib/kulala-core/kulala-core.js \
      --set KULALA_CURL_PATH ${lib.getExe curl}

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    kulalaResponse=$(
      printf '%s' '{"action":"from_curl","curl":"curl https://example.com"}' | \
        $out/bin/kulala-core
    )
    [[ "$kulalaResponse" = *'"ok": true'* ]]
    [[ "$kulalaResponse" = *'GET https://example.com'* ]]

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  dontConfigure = true;

  node_modules = stdenv.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-node_modules";
    strictDeps = true;

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
      cp -R node_modules $out/

      runHook postInstall
    '';

    __structuredAttrs = true;
    dontConfigure = true;
    dontFixup = true;
    outputHash = "sha256-jvl3eJvweE7ZTcOaa9qTe9UwGzouK+6WUREkgRhYJfc=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  meta = {
    description = "HTTP client library powering the Kulala toolchain";
    homepage = "https://github.com/mistweaverco/kulala-core";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    platforms = bun.meta.platforms;
    mainProgram = "kulala-core";
  };
})
