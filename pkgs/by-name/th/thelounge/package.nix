{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  fetchYarnDeps,
  fixup-yarn-lock,
  nixosTests,
  nodejs-slim,
  npmHooks,
  sqlite,
  srcOnly,
  xcbuild,
  yarn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thelounge";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "thelounge";
    repo = "thelounge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I+ITSEm/FCI4omeBM8BCowI6hXBYriJfZ0vP27771Ms=";
  };

  # Allow setting package path for the NixOS module.
  patches = [ ./packages-path.patch ];

  # Use the NixOS module's state directory by default.
  postPatch = ''
    echo /var/lib/thelounge > .thelounge_home
  '';

  nativeBuildInputs = [
    nodejs-slim
    nodejs-slim.npm
    yarn
    fixup-yarn-lock
    npmHooks.npmInstallHook
  ];

  buildPhase = ''
    runHook preBuild

    NODE_ENV=production yarn build

    runHook postBuild
  '';

  # `npm prune` doesn't work and/or hangs for whatever reason.
  preInstall = ''
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive --production
    patchShebangs node_modules
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$PWD"

    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror ${finalAttrs.offlineCache}
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules

    runHook postConfigure
  '';

  disallowedReferences = [ nodejs-slim.src ];
  dontNpmPrune = true;
  # Takes way, way, way too long.
  dontStrip = true;

  offlineCache = fetchYarnDeps {
    hash = "sha256-wgG5AGZvMzdw4QnTNOzAfQGB//VWlV403AgWv4TceGQ=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests = nixosTests.thelounge;

  meta = {
    inherit (nodejs-slim.meta) platforms;
    description = "Modern, responsive, cross-platform, self-hosted web IRC client";
    homepage = "https://thelounge.chat";
    changelog = "https://github.com/thelounge/thelounge/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      winter
    ];

    mainProgram = "thelounge";
  };
})
