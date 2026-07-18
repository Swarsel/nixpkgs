{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  pname = "filen-cli";
  version = "0.0.36";

  src = fetchFromGitHub {
    owner = "FilenCloudDienste";
    repo = "filen-cli";
    tag = "v${version}";
    hash = "sha256-2FN9KygSGir/vtHdKXX0zUeug2O6tgAc1PBhzD9HPqY=";
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
        --force \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';

    dontConfigure = true;
    dontFixup = true;

    outputHash =
      {
        aarch64-darwin = "sha256-+nTCiCEXsEz7YqRZkHlP3CWL7e7OPdds33BTwfqTL5c=";
        aarch64-linux = "sha256-uvL498mHFXwoZpeCwsup4Iyh4l5buVnqLRBMyGVRIlA=";
        x86_64-linux = "sha256-Ky+ewpdd5nKvRzXwEAUgT7P/OW3v6fdb2r6SGxZ/JEc=";
      }
      .${stdenv.hostPlatform.system}
        or (throw "${pname}: Platform ${stdenv.hostPlatform.system} is not packaged yet.");

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    bun build \
      --compile \
      --target=bun \
      --minify \
      --sourcemap src/index.ts \
      --outfile dist/filen \
      --define IS_RUNNING_AS_BINARY=true \
      --define "VERSION=v${version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./dist/filen $out/bin

    wrapProgram $out/bin/filen \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/node_modules .

    runHook postConfigure
  '';

  # strip removes the JS bundle from the binary
  dontStrip = true;

  preVersionCheck = ''
    cat > filen-version << EOF
    #!/bin/sh
    exec $out/bin/filen --skip-update "\$@"
    EOF
    chmod +x filen-version
    versionCheckProgram="$(pwd)/filen-version"
  '';

  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "CLI tool for interacting with the Filen cloud";
    homepage = "https://github.com/FilenCloudDienste/filen-cli";
    changelog = "https://github.com/FilenCloudDienste/filen-cli/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ eilvelia ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "filen";
  };
}
