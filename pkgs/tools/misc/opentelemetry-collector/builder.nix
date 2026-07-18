{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "ocb";
  # Also update `pkgs/tools/misc/opentelemetry-collector/releases.nix`
  # whenever that version changes.
  version = "0.155.0";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-collector";
    rev = "cmd/builder/v${version}";
    hash = "sha256-EG//ddcXolvILucKYWZSoeqgFCE7u3/h8v/oX3pzafk=";
  };

  vendorHash = "sha256-SeLEg/xwSEr3uPZbjlLFny+OpfovcmKVD6BxCgoosz8=";
  env.CGO_ENABLED = 0;

  # Some tests download new dependencies for a modified go.mod. Nix doesn't allow network access so skipping.
  checkFlags = [
    "-skip TestGenerateAndCompile|TestReplaceStatementsAreComplete|TestVersioning|TestRunInit"
  ];

  # Rename to ocb (it's generated as "builder")
  postInstall = ''
    mv $out/bin/builder $out/bin/ocb
  '';

  ldflags = [
    "-s"
    "-w"
    "-X go.opentelemetry.io/collector/cmd/builder/internal.version=${version}"
  ];

  sourceRoot = "${src.name}/cmd/builder";

  meta = {
    description = "OpenTelemetry Collector";
    homepage = "https://github.com/open-telemetry/opentelemetry-collector.git";
    changelog = "https://github.com/open-telemetry/opentelemetry-collector/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "ocb";
  };
}
