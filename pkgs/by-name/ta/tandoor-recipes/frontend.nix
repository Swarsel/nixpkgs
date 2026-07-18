{
  stdenv,
  callPackage,
  fetchYarnDeps,
  fixup-yarn-lock,
  nodejs_22,
  yarn,
}:
let
  common = callPackage ./common.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (common) version;
  pname = "tandoor-recipes-frontend";
  src = "${common.src}/vue3";

  nativeBuildInputs = [
    fixup-yarn-lock
    nodejs_22
    (yarn.override { nodejs = nodejs_22; })
  ];

  buildPhase = ''
    runHook preBuild

    yarn --offline run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -R ../cookbook/static/vue3/ $out
    echo "${common.version}" > "$out/version"

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
    fixup-yarn-lock yarn.lock
    command -v yarn
    yarn install --frozen-lockfile --offline --no-progress --non-interactive
    patchShebangs node_modules/

    runHook postConfigure
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = common.yarnHash;
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = common.meta // {
    description = "Tandoor Recipes frontend";
  };
})
