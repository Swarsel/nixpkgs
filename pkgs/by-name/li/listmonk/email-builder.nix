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

stdenv.mkDerivation {
  inherit version;
  inherit meta;
  pname = "listmonk-email-builder";
  src = "${src}/frontend/email-builder";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R dist/* $out
    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-ANPLOL9j0gljtNtbfb+ZifVRN9vLexPddAevpeFwX4o=";
    yarnLock = "${src}/frontend/email-builder/yarn.lock";
  };
}
