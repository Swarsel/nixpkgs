{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "vfox";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "version-fox";
    repo = "vfox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dTs+GY3R01pUWINLnZqGg3HBWVsLvSlhxrnecznXeZk=";
  };

  vendorHash = "sha256-494nqL6KiUk4VeKlG9YHFpgACgaYC3SR1I1EViD71Jw=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags =
    let
      skippedTests = [
        # need network
        "TestGetRequest"
        "TestHeadRequest"
        "TestDownloadFile"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    export CI=1
  '';

  __darwinAllowLocalNetworking = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extendable version manager";
    homepage = "https://github.com/version-fox/vfox";
    changelog = "https://github.com/version-fox/vfox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "vfox";
  };
})
