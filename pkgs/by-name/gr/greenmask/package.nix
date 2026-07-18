{
  lib,
  fetchFromGitHub,
  buildGoModule,
  coreutils,
}:

buildGoModule (finalAttrs: {
  pname = "greenmask";
  version = "0.2.22";

  src = fetchFromGitHub {
    owner = "GreenmaskIO";
    repo = "greenmask";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bmKy3naQiLG4z3+VNkUck3UNVh2Oi8faXRz20qjwL9g=";
  };

  vendorHash = "sha256-PsGeh7PzZFFhzQClW56GfvsGp8T7dccyErdnOv3urhs=";
  nativeCheckInputs = [ coreutils ];

  preCheck = ''
    substituteInPlace internal/db/postgres/transformers/custom/dynamic_definition_test.go \
      --replace-fail "/bin/echo" "${coreutils}/bin/echo"

    substituteInPlace tests/integration/greenmask/main_test.go \
      --replace-fail "TestTocLibrary" "SkipTestTocLibrary" \
      --replace-fail "TestGreenmaskBackwardCompatibility" "SkipTestGreenmaskBackwardCompatibility"
    substituteInPlace tests/integration/storages/main_test.go \
      --replace-fail "TestS3Storage" "SkipTestS3Storage"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/greenmaskio/greenmask/cmd/greenmask/cmd.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/greenmask/" ];

  meta = {
    description = "PostgreSQL database anonymization tool";
    homepage = "https://github.com/GreenmaskIO/greenmask";
    changelog = "https://github.com/GreenmaskIO/greenmask/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "greenmask";
  };
})
