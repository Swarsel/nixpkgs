{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  chromium,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeWrapper,
  nodejs,
  yarn,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aws-azure-login";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "aws-azure-login";
    repo = "aws-azure-login";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PvPnqaKD98h3dCjEOwF+Uc86xCJzn2b9XNHHn13h/2Y=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    fixup-yarn-lock
    yarn
  ];

  buildPhase = ''
    runHook preBuild

    yarn --offline build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out/lib/node_modules/aws-azure-login"
    cp -r . "$out/lib/node_modules/aws-azure-login"

    makeWrapper "${nodejs}/bin/node" "$out/bin/aws-azure-login" \
      --add-flags "$out/lib/node_modules/aws-azure-login/lib/index.js" \
      --set PUPPETEER_EXECUTABLE_PATH "${lib.getExe chromium}"

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$offlineCache"
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install
    patchShebangs node_modules

    runHook postConfigure
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-SXQPRzF6b1FJl5HkyXNm3kGoNSDXux+0RYXBX93mOts=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests.aws-azure-login = callPackage ./tests.nix {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Use Azure AD SSO to log into the AWS via CLI";
    homepage = "https://github.com/aws-azure-login/aws-azure-login";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ l0b0 ];
    platforms = lib.platforms.all;
    mainProgram = "aws-azure-login";
  };
})
