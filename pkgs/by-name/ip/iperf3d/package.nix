{
  lib,
  fetchFromGitHub,
  iperf3,
  makeWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iperf3d";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "wobcom";
    repo = "iperf3d";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pMwGoBgFRVY+H51k+YCamzHgBoaJVwEVqY0CvMPvE0w=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-eijsPyoe3/+yR5kRmzk0dH62gTAFFURTVT8wN6Iy0HI=";

  postInstall = ''
    wrapProgram $out/bin/iperf3d --prefix PATH : ${iperf3}/bin
  '';

  meta = {
    description = "Iperf3 client and server wrapper for dynamic server ports";
    homepage = "https://github.com/wobcom/iperf3d";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      netali
      johannwagner
    ];

    mainProgram = "iperf3d";
  };
})
