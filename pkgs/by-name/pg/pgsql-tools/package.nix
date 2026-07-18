{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libxcrypt-legacy,
  makeBinaryWrapper,
  pgsql-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pgsql-tools";
  version = "2.1.0";

  src = fetchurl (
    let
      sources = {
        aarch64-darwin = {
          hash = "sha256-tpabEKB1kqse7D58FsP/9jywk+vgAAvptL9MadwxWg8=";
          url = "https://github.com/microsoft/pgsql-tools/releases/download/v${finalAttrs.version}/pgsqltoolsservice-osx-arm64.tar.gz";
        };

        aarch64-linux = {
          hash = "sha256-rD8jymGdM1RDGDbrKu6E7xoWtSMRNuc2ngCmR+sHgQI=";
          url = "https://github.com/microsoft/pgsql-tools/releases/download/v${finalAttrs.version}/pgsqltoolsservice-linux-arm64.tar.gz";
        };

        x86_64-linux = {
          hash = "sha256-dN7+LJCUwb39ypuJV4p3jUHNGAPaObN4aZvsOHIpmkQ=";
          url = "https://github.com/microsoft/pgsql-tools/releases/download/v${finalAttrs.version}/pgsqltoolsservice-linux-x64.tar.gz";
        };
      };
    in
    sources.${stdenv.hostPlatform.system}
  );

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxcrypt-legacy
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/pgsql-tools
    install -Dm755 ossdbtoolsservice_main $out/lib/pgsql-tools/ossdbtoolsservice_main
    cp -r _internal $out/lib/pgsql-tools/

    makeBinaryWrapper $out/lib/pgsql-tools/ossdbtoolsservice_main $out/bin/ossdbtoolsservice_main \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''--prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libxcrypt-legacy
          (lib.getLib stdenv.cc.cc)
        ]
      }"''} \
      --chdir $out/lib/pgsql-tools

    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;
  dontStrip = true;

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Backend service for PostgreSQL server tools, offering features such as connection management, query execution with result set handling, and language service support via the VS Code protocol";
    homepage = "https://github.com/microsoft/pgsql-tools";
    changelog = "https://github.com/microsoft/pgsql-tools/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ossdbtoolsservice_main";
  };
})
