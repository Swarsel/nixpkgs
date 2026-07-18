{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libpcap,
}:

buildGoModule (finalAttrs: {
  pname = "lprobe";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "fivexl";
    repo = "lprobe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eR4WJD0Wa1+erwrmZBfH3wD1iSjH9s33nxaO+6bwMGE=";
  };

  buildInputs = [
    libpcap
  ];

  vendorHash = "sha256-kA4vXOOaQicjaoQeQest1NPAXXK4hmMXz2uFo4QGWO8=";

  meta = {
    description = "Command-line tool to perform Local Health Check Probes inside Container Images (ECS, Docker)";
    homepage = "https://github.com/fivexl/lprobe";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cageyv ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "lprobe";
  };
})
