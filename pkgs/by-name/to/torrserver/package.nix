{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  ffmpeg,
  makeWrapper,
}:
buildGo126Module rec {
  pname = "torrserver";
  version = "142";

  src = fetchFromGitHub {
    owner = "YouROK";
    repo = "TorrServer";
    tag = "MatriX.${version}";
    sha256 = "sha256-bAnnDbrKYfU3WdjwIW4GGDST4S13KIhGNoQQtI27UaQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-B5BAmdFuLWDkbp/lehFziyHXcMPIAgNySgTPv9Nv680=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/torrserver

    wrapProgram $out/bin/torrserver \
      --set PATH ${lib.makeBinPath [ ffmpeg ]}
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  modRoot = "server";
  subPackages = [ "cmd" ];

  meta = {
    description = "Simple and powerful tool for streaming torrents";
    homepage = "https://github.com/YouROK/TorrServer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ r4v3n6101 ];
  };
}
