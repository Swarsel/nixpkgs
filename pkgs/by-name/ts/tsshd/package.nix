{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tsshd";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "trzsz";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-YqSSJA/jP8WRbfwC5fxFE4su01ZEPQNmiNRr96pDE1g=";
  };

  vendorHash = "sha256-HJWxphZuBh3gXPoEqL/EVGtwdWyW+cMSQhKyfSymKG0=";

  nativeCheckInputs = [
    versionCheckHook
  ];

  checkFlags =
    let
      skippedTests = [
        # `quic.DialAddr` of `quic-go` invokes UDP writing with `sendmsg` from address `[::]`,
        # causing these tests to fail even with the `__darwinAllowLocalNetworking` flag enabled.
        "TestQUIC_InitialPacketSize"
        "TestQUIC_RespectMTU"
        "TestQUIC_CertValidation"
      ];
    in
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
    ];

  doInstallCheck = true;
  # Enable for upstream KCP and QUIC tests which require UDP binding on localhost
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Server for `trzsz-ssh`(`tssh`) that supports connection migration for roaming";
    homepage = "https://github.com/trzsz/tsshd";
    changelog = "https://github.com/trzsz/tsshd/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ljxfstorm ];
    mainProgram = "tsshd";
  };
})
