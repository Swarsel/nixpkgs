{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cog,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "cog";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "cog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hYXTZlV8128cKchF2vMkr4QJxYI+yJA75LtuTmMpR5U=";
  };

  vendorHash = "sha256-5y6spoRzl4yJ5GpiHHvGHJIdEFnsUdpIiuoWmym5GJY=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    mv $out/bin/cli $out/bin/cog
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/cli" ];
  passthru.tests.version = testers.testVersion { package = cog; };

  meta = {
    description = "Grafana's code generation tool";
    homepage = "https://github.com/grafana/cog";
    changelog = "https://github.com/grafana/cog/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.zebradil
    ];

    mainProgram = "cog";
  };
})
