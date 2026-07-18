{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hermit";
  version = "0.52.1";

  src = fetchFromGitHub {
    owner = "cashapp";
    repo = "hermit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+3iP+cJBa+EHVw+xWyH6tyaeqbzOr8E30Ig2Xr5MPkg=";
  };

  vendorHash = "sha256-2sNtok5J1kBvJZ0I1FOq1ZP54TsZbzqu/M3v1nA12m8=";

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.channel=stable"
  ];

  subPackages = [ "cmd/hermit" ];

  meta = {
    description = "Manages isolated, self-bootstrapping sets of tools in software projects";
    homepage = "https://cashapp.github.io/hermit";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cbrewster ];
    platforms = lib.platforms.unix;
    mainProgram = "hermit";
  };
})
