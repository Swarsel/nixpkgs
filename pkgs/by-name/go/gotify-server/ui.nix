{
  stdenv,
  fetchYarnDeps,
  nodejs-slim,
  src,
  version,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "gotify-ui";
  src = src + "/ui";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs-slim
  ];

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  installPhase = ''
    runHook preInstall

    mv build $out

    runHook postInstall
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-MKHpdRxL12T4/JVPCUE7nQresxnRBs9kvWGvfAhMESM=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };
})
