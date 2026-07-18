{
  stdenv,
  fetchYarnDeps,
  meta,
  nodejs,
  src,
  version,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  inherit meta;
  pname = "listmonk-frontend";
  src = "${src}/frontend";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    mkdir -p $out/admin
    cp -R dist/* $out/admin
    cp node_modules/altcha/dist/altcha.umd.cjs $out/altcha.umd.js
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-R2xHcHksTtFfFh41FLeBhpuz84ceixGt6oz6SQWWyMQ=";
    yarnLock = "${src}/frontend/yarn.lock";
  };
})
