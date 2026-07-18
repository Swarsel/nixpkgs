{
  lib,
  stdenv,
  fetchurl,
  jdk11_headless,
  jre11_minimal,
  makeBinaryWrapper,
  nix-update-script,
  versionCheckHook,
}:
let
  jre11_minimal_headless = jre11_minimal.override {
    jdk = jdk11_headless;

    modules = [
      "java.logging"
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rundeck-cli";
  version = "2.0.10";

  src = fetchurl {
    url = "https://github.com/rundeck/rundeck-cli/releases/download/v${finalAttrs.version}/rundeck-cli-${finalAttrs.version}-all.jar";
    hash = "sha256-RiGWsscenvNpKr+yOHpy2F7dPZ3M/R9SWD+EKF7nq18=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = [ jre11_minimal_headless ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rundeck-cli
    cp $src $out/share/rundeck-cli/rundeck-cli.jar

    mkdir -p $out/bin
    makeWrapper ${lib.getExe jre11_minimal_headless} $out/bin/rd \
      --add-flags "-jar $out/share/rundeck-cli/rundeck-cli.jar"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontUnpack = true;
  versionCheckProgram = "${placeholder "out"}/bin/rd";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Official CLI tool for Rundeck";

    longDescription = ''
      The rd command provides command line access to the Rundeck HTTP API,
      allowing you to access and control your Rundeck server from the
      command line or shell scripts.
    '';

    homepage = "https://github.com/rundeck/rundeck-cli";
    changelog = "https://github.com/rundeck/rundeck-cli/blob/v${finalAttrs.version}/docs/changes.md";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = lib.platforms.unix;
    mainProgram = "rd";
  };
})
