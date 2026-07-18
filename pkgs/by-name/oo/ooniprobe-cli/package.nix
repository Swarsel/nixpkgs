{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ooniprobe-cli";
  version = "3.29.1";

  src = fetchFromGitHub {
    owner = "ooni";
    repo = "probe-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l45gVWddIQpVb3VDQ44K0MEjLiowLX120S0R/EMrAJU=";
  };

  vendorHash = "sha256-kbvdUqAz9k3AHtitoVr4q1kGMf2Jzfs6iSRUl1sp4UU=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/ooniprobe" ];

  meta = {
    description = "Open Observatory of Network Interference command line network probe";
    homepage = "https://ooni.org/install/cli";
    changelog = "https://github.com/ooni/probe-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "ooniprobe";
  };
})
