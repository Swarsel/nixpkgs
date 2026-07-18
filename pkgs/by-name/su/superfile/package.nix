{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  exiftool,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:
let
  version = "1.3.3";
  tag = "v${version}";
in
buildGoModule {
  inherit version;
  pname = "superfile";

  src = fetchFromGitHub {
    inherit tag;
    owner = "yorukot";
    repo = "superfile";
    hash = "sha256-A1SWsBcPtGNbSReslp5L3Gg4hy3lDSccqGxFpLfVPrk=";
  };

  nativeBuildInputs = [ exiftool ];
  vendorHash = "sha256-sqt0BzJW1nu6gYAhscrXlTAbwIoUY7JAOuzsenHpKEI=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  # Upstream notes that this could be flaky, and it consistently fails for me.
  checkFlags = [
    "-skip=^TestReturnDirElement/Sort_by_Date$"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Only failing on nix darwin. I suspect this is due to the way
    # darwin handles file permissions.
    "-skip=^TestCompressSelectedFiles"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pretty fancy and modern terminal file manager";
    homepage = "https://github.com/yorukot/superfile";
    changelog = "https://github.com/yorukot/superfile/blob/${tag}/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      redyf
    ];

    mainProgram = "superfile";
  };
}
