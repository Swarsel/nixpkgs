{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "falcoctl";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "falcosecurity";
    repo = "falcoctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BEnThboYmcZKL1o6Js8zHWvbU1OSH7BRcohBzlqNZKI=";
  };

  vendorHash = "sha256-SIEd/YVwEF4FleudzvYoOW2GnIflKMYRDEiWSv77H7o=";
  # require network
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/falcosecurity/falcoctl/cmd/version.semVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "Administrative tooling for Falco";
    homepage = "https://github.com/falcosecurity/falcoctl";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      developer-guy
      kranurag7
      LucaGuerra
    ];

    mainProgram = "falcoctl";
  };
})
