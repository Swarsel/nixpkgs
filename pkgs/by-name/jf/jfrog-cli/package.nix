{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nodejs,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "jfrog-cli";
  version = "2.113.0";

  src = fetchFromGitHub {
    owner = "jfrog";
    repo = "jfrog-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AcydCwarePzysegEH9QUgbp0v2SP8J56rAYFBF6FxO0=";
  };

  vendorHash = "sha256-gghTbLH/o88u9smpe5gDUM0a4Zk0x/J9unABnqaKo58=";

  nativeCheckInputs = [
    nodejs
    writableTmpDirAsHomeHook
  ];

  checkFlags = "-skip=^(TestReleaseBundle|TestVisibilitySendUsage_RtCurl_E2E)";

  postInstall = ''
    # Name the output the same way as the original build script does
    mv $out/bin/jfrog-cli $out/bin/jf
  '';

  __darwinAllowLocalNetworking = true;
  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client for accessing to JFrog's Artifactory and Mission Control through their respective REST APIs";
    homepage = "https://github.com/jfrog/jfrog-cli";
    changelog = "https://github.com/jfrog/jfrog-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      detegr
    ];

    mainProgram = "jf";
  };
})
