{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kt";
  version = "13.1.0";

  src = fetchFromGitHub {
    owner = "fgeller";
    repo = "kt";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1UGsiMMmAyIQZ62hNIi0uzyX2uNL03EWupIazjznqDc=";
  };

  vendorHash = "sha256-PeNpDro6G78KLN6B2CDhsTKamRTWQyxPJYWuuv6sUyw=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Kafka command line tool";
    homepage = "https://github.com/fgeller/kt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ utdemir ];
    platforms = with lib.platforms; unix;
    mainProgram = "kt";
  };
})
