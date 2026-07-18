{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "cagent";
  version = "1.20.6";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "docker-agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jcJxzdtU0Zzov7EKvJCxgbrfwMcI4k7OgHVrb5S4fs8=";
  };

  vendorHash = "sha256-aldMwGMRF8VhdgNwp/wrRR1kLmiGsi76rmTGcKutm7c=";
  # Disable tests: Networked model providers and writable cache directories are required.
  doCheck = false;
  # Skip install checks on macOS: The build sandbox is missing the `/etc/protocols` file, which is required for validation.
  doInstallCheck = !stdenv.hostPlatform.isDarwin;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/docker/cagent/pkg/version.Version=${finalAttrs.version}"
    "-X"
    "github.com/docker/cagent/pkg/version.Commit=${finalAttrs.src.tag}"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Agent Builder and Runtime by Docker Engineering";

    longDescription = ''
      A powerful, easy-to-use, customizable multi-agent runtime that
      orchestrates AI agents with specialized capabilities and tools,
      and the interactions between agents.
    '';

    homepage = "https://github.com/docker/docker-agent";
    changelog = "https://github.com/docker/docker-agent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ MH0386 ];
    mainProgram = "cagent";
    downloadPage = "https://github.com/docker/docker-agent/releases";
  };
})
