{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "woke";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "get-woke";
    repo = "woke";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X9fhExHhOLjPfpwrYPMqTJkgQL2ruHCGEocEoU7m6fM=";
  };

  vendorHash = "sha256-lRUvoCiE6AkYnyOCzev1o93OhXjJjBwEpT94JTbIeE8=";
  # Tests require internet access and/or fail when building with Nix
  doCheck = false;
  postInstall = "rm $out/bin/docs";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/get-woke/woke/cmd.Version=${finalAttrs.version}"
    "-X=github.com/get-woke/woke/cmd.Commit=${finalAttrs.src.tag}"
    "-X=github.com/get-woke/woke/cmd.Date=1970-01-01T00:00:00Z"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/woke";

  meta = {
    description = "Detect non-inclusive language in your source code";
    homepage = "https://github.com/get-woke/woke";
    changelog = "https://github.com/get-woke/woke/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    mainProgram = "woke";
  };
})
