{
  stdenv,
  fetchYarnDeps,
  fixup-yarn-lock,
  meta,
  nodejs,
  src,
  version,
  yarn,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit src version;
  pname = "lasuite-drive-frontend";
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    fixup-yarn-lock
    yarn
    yarnConfigHook
    yarnBuildHook
  ];

  installPhase = ''
    runHook preInstall

    cp -r apps/drive/out/ $out

    runHook postInstall
  '';

  __structuredAttrs = true;

  offlineCache = fetchYarnDeps {
    hash = "sha256-W0Sp8G7Lt9UMND8+ZLD8oxrNCgGpQph23AvQpynYWYI=";
    yarnLock = "${finalAttrs.src}/src/frontend/yarn.lock";
  };

  sourceRoot = "${finalAttrs.src.name}/src/frontend";

  meta = meta // {
    description = "A collaborative file sharing and document management platform that scales. Built with Django and React. Opensource alternative to Sharepoint or Google Drive";
  };
})
