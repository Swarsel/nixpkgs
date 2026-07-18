{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_24,
}:

buildNpmPackage.override { nodejs = nodejs_24; } (finalAttrs: {
  pname = "mongosh";
  version = "2.9.2";

  src = fetchFromGitHub {
    owner = "mongodb-js";
    repo = "mongosh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mwc9Mv8BJgI/7DzUH6QwHsWzgAquB8ehmnElM5+mYuI=";
  };

  patches = [
    ./disable-telemetry.patch
  ];

  npmDepsHash = "sha256-xI+6a0sMuZmij46N5aqsprLLiVaSZifGW8tMq189fww=";

  installPhase = ''
    runHook preInstall
    npmWorkspace=packages/mongosh npmInstallHook
    cp -r packages configs $out/lib/node_modules/mongosh/
    rm $out/lib/node_modules/mongosh/node_modules/@mongosh/docker-build-scripts # dangling symlink
    runHook postInstall
  '';

  dontNpmInstall = true;
  npmBuildScript = "compile";

  npmFlags = [
    "--omit=optional"
    "--ignore-scripts"
  ];

  passthru = {
    # Version testing is skipped because upstream often forgets to update the version.

    updateScript = ./update.sh;
  };

  meta = {
    description = "MongoDB Shell";
    homepage = "https://www.mongodb.com/try/download/shell";
    changelog = "https://github.com/mongodb-js/mongosh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "mongosh";
  };
})
