{
  lib,
  fetchYarnDeps,
  hash,
  meta,
  nodejs_22,
  pname,
  sourceDir,
  src,
  stdenvNoCC,
  version,
  yarnBuildHook,
  yarnConfigHook,
  extraFiles ? "",
  yarnLock ? null,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    src
    meta
    ;

  postPatch = lib.optionalString (yarnLock != null) ''
    cp ${yarnLock} ./yarn.lock
  '';

  nativeBuildInputs = [
    nodejs_22
    yarnBuildHook
    yarnConfigHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/* ${extraFiles} $out

    runHook postInstall
  '';

  BUILD_VERSION = finalAttrs.version;
  sourceRoot = "${finalAttrs.src.name}/${sourceDir}";

  yarnOfflineCache = fetchYarnDeps {
    inherit hash;
    yarnLock = if yarnLock != null then yarnLock else "${finalAttrs.src}/${sourceDir}/yarn.lock";
  };
})
