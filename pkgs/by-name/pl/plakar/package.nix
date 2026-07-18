{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo125Module,
  fuse,
  installShellFiles,
}:
buildGo125Module (finalAttrs: {
  pname = "plakar";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "PlakarKorp";
    repo = "plakar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Urj1BG3XGhSroaa9pl9NGiKj38J1P+H9sA7noGwIhdc=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    fuse
  ];

  vendorHash = "sha256-aqHjSTVVxBbaHAZZNQaFbftN0Hbl/+7wgk5uFM664po=";

  checkFlags =
    let
      skippedTests = [
        # hangs even outside Nix, so probably an upstream issue:
        "TestRebuildStateVersionMismatch"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "TestBTreeScanMemory"
        "TestBTreeScanPebble"
        "TestExecuteCmdServerDefault"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    installManPage $(find $src -regex '.*\.[0-9]$')
  '';

  # to avoid having all the Test(Get|Set|Validate)Service.* tests fail on darwin
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Encrypted, queryable backups for engineers based on an immutable data store and portable archives";
    homepage = "https://www.plakar.io";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      heph2
      qbit
      nadir-ishiguro
    ];

    mainProgram = "plakar";
  };
})
