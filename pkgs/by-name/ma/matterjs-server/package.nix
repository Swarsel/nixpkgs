{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  nix-update-script,
  nixosTests,
  nodejs,
  udev,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "matterjs-server";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "matter-js";
    repo = "matterjs-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IXYq4Ppz61+8PeGUgmBcENkL3o6JFrJaIwFjr77uOhg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    versionCheckHook
  ];

  buildInputs = [ udev ];
  npmDepsHash = "sha256-HrBtwT61RnHSuUCGH9I6vcigzpZdwp6HS5dc0v3EVnQ=";
  env.CXXFLAGS = "-std=c++20";
  preBuild = "npm run version -- --apply";

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-save

    mkdir -p $out/lib/matterjs-server
    cp -r node_modules packages $out/lib/matterjs-server/

    makeWrapper ${lib.getExe nodejs} $out/bin/matterjs-server \
      --add-flags "$out/lib/matterjs-server/packages/matter-server/dist/esm/MatterServer.js" \
      "''${makeWrapperArgs[@]}"

    runHook postInstall
  '';

  doInstallCheck = true;
  __structuredAttrs = true;
  dontNpmInstall = true;

  makeWrapperArgs = [
    "--set"
    "NODE_OPTIONS"
    "--enable-source-maps"
  ];

  versionCheckProgramArg = "--version";

  passthru = {
    tests = { inherit (nixosTests) matterjs-server; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matter server based on Matter.js";
    homepage = "https://github.com/matter-js/matterjs-server";
    changelog = "https://github.com/matter-js/matterjs-server/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kranzes
      marie
    ];

    platforms = lib.platforms.linux;
    mainProgram = "matterjs-server";
  };
})
