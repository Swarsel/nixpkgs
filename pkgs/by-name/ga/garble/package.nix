{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo125Module,
  git,
  nix-update-script,
  replaceVars,
  versionCheckHook,
}:

buildGo125Module (finalAttrs: {
  pname = "garble";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "burrowers";
    repo = "garble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9Vjv5Eis+ALUm2aaXOj4i8w3UmylPggMXqgwXtD2YA8=";
  };

  patches = [
    (replaceVars ./0001-Add-version-info.patch {
      inherit (finalAttrs) version;
    })
  ];

  vendorHash = "sha256-EOmAb2k9LSzsvumsCZdeJIDKQBJBeRFt15mWAyyVl1k=";
  # Several tests fail with
  # FAIL: testdata/script/goenv.txtar:27: "$WORK/.temp 'quotes' and spaces" matches "garble|importcfg|cache\\.gob|\\.go"
  doCheck = !stdenv.hostPlatform.isDarwin;

  # Used for some of the tests.
  nativeCheckInputs = [
    git
    versionCheckHook
  ];

  checkFlags = [
    "-skip"
    "TestScript/gogarble|TestScript/gotoolchain|TestScript/tiny"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export WORK=$(mktemp -d)
  '';

  doInstallCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-buildid=00000000000000000000" # length=20
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Obfuscate Go code by wrapping the Go toolchain";
    homepage = "https://github.com/burrowers/garble/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      davhau
      bot-wxt1221
    ];

    mainProgram = "garble";
  };
})
