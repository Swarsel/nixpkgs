{
  lib,
  stdenv,
  fetchFromGitHub,
  chromium, # Can be overwritten to be (potentially) any Chromium implementation
  fetchYarnDeps,
  makeWrapper,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "google-lighthouse";
  version = "13.4.0";

  src = fetchFromGitHub {
    owner = "GoogleChrome";
    repo = "lighthouse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-diZT1SOCSpuiQfAS7kjGxea2imVAJyKYxf2WFBsE/H0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    chromium
    nodejs
  ];

  postCheck = ''
    yarn unit
    yarn test-clients
    yarn test-docs
    yarn test-treemap
  '';

  postInstall = ''
    wrapProgram "$out/bin/lighthouse" \
      --set CHROME_PATH ${lib.getExe chromium}
  '';

  doDist = false;
  yarnBuildScript = "build-report";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-Rp+LCYRZ5jVGiR1L8Wyd5juw8GPrwnUH2chrxrrwE6k=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automated auditing, performance metrics, and best practices for the web";
    homepage = "https://developer.chrome.com/docs/lighthouse/overview";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ theCapypara ];
    mainProgram = "lighthouse";
  };
})
