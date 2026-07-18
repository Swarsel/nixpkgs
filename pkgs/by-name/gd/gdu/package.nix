{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gdu";
  version = "5.36.1";

  src = fetchFromGitHub {
    owner = "dundee";
    repo = "gdu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jtIVfXCIuJPsw3ryJiMI9W0L2uMeCGKt/7dWCS519fI=";
  };

  postPatch = ''
    substituteInPlace cmd/gdu/app/app_test.go \
      --replace-fail "development" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  vendorHash = "sha256-L3nuVoxr+LqBT/9TrwAxJEOxOr53KlXH8rWsFTt2SNc=";
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkFlags =
    let
      skippedTests = [
        "TestStoredAnalyzer" # https://github.com/dundee/gdu/issues/371
        "TestAnalyzePathWithIgnoring"
        "TestTopDirFollowSymlink"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    installManPage gdu.1
  '';

  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/dundee/gdu/v${lib.versions.major finalAttrs.version}/build.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Disk usage analyzer with console interface";

    longDescription = ''
      Gdu is intended primarily for SSD disks where it can fully
      utilize parallel processing. However HDDs work as well, but
      the performance gain is not so huge.
    '';

    homepage = "https://github.com/dundee/gdu";
    changelog = "https://github.com/dundee/gdu/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      fab
      zowoq
    ];

    mainProgram = "gdu";
  };
})
