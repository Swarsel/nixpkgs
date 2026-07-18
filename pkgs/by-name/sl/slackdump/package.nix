{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  darwin,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "slackdump";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "rusq";
    repo = "slackdump";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ds3nggx1f389goOWelYXNviFRZ/h4XX54LgtU9oqklc=";
  };

  vendorHash = "sha256-fRvtdl0+uVhN6cQJxRsOw1vQsrcsPvcn/Tb7US7MKmM=";
  nativeCheckInputs = lib.optional stdenv.hostPlatform.isDarwin darwin.IOKitTools;

  checkFlags =
    let
      skippedTests = [
        "TestSession_saveUserCache"
        "TestSession_GetUsers"
        "Test_exportV3" # This was skipped on upstream's CI. It is seemed that some file are missed
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "TestWithRetry" # flaky timing-sensitive test on darwin
      ];
    in
    [
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
    ];

  __darwinAllowLocalNetworking = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools for saving Slack's data without admin privileges";
    homepage = "https://github.com/rusq/slackdump";
    changelog = "https://github.com/rusq/slackdump/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    mainProgram = "slackdump";
  };
})
