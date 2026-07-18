{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "diun";
  version = "4.33.0";

  src = fetchFromGitHub {
    owner = "crazy-max";
    repo = "diun";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EVIT6au5B3wzb5xTc2o/sY7p3+tT5lWjlzQX5HdQNkA=";
  };

  vendorHash = null;
  # upstream disable CGO in release build
  # https://github.com/crazy-max/diun/blob/76c0fe99212adc58d6a3433bbcde1ffa9fb879c4/Dockerfile#L11
  env.CGO_ENABLED = 0;

  checkFlags =
    let
      # these tests require a network connection
      skippedTests = [
        "TestTags"
        "TestTagsWithDigest"
        "TestCompareDigest"
        "TestManifest"
        "TestManifestMultiUpdatedPlatform"
        "TestManifestMultiNotUpdatedPlatform"
        "TestManifestVariant"
        "TestManifestTaggedDigest"
        "TestManifestTaggedDigestUnknownTag"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/diun
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI application to receive notifications when a Docker image is updated on a Docker registry";
    homepage = "https://crazymax.dev/diun";
    changelog = "https://crazymax.dev/diun/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Sped0n ];
    platforms = lib.platforms.unix;
    mainProgram = "diun";
  };
})
