{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "s5cmd";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "peak";
    repo = "s5cmd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+wSVJkXmu+1BzvO1o31jhKZLXeG7y+YkABIZZ1TlK/g=";
  };

  vendorHash = null;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Fix tests creating network sockets on macOS
  __darwinAllowLocalNetworking = true;
  # Skip e2e tests requiring network access
  excludedPackages = [ "./e2e" ];
  ldflags = [ "-X github.com/peak/s5cmd/v2/version.Version=v${finalAttrs.version}" ];
  versionCheckProgramArg = [ "version" ];

  meta = {
    description = "Parallel S3 and local filesystem execution tool";
    homepage = "https://github.com/peak/s5cmd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomberek ];
    mainProgram = "s5cmd";
  };
})
