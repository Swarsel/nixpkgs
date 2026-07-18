{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "lstk";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "localstack";
    repo = "lstk";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-OqJhHJFSQ8tJDcFizXky40W5nedSroUVXGrXAWTHnlQ=";
  };

  vendorHash = "sha256-ZWezMbvUUwOoWMU+zHL4hHMKAncI/oCsWMaLt5qN+YM=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  excludedPackages = "test/integration";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line interface for LocalStack";

    longDescription = ''
      lstk is a command-line interface for LocalStack built in Go with a modern
      terminal Ul, and native CLI experience for managing and interacting with
      LocalStack deployments.
    '';

    homepage = "https://github.com/localstack/lstk";
    changelog = "https://github.com/localstack/lstk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ purcell ];
    platforms = lib.platforms.unix;
    mainProgram = "lstk";
  };
})
