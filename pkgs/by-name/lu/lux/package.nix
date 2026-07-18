{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "lux";
  version = "0.24.1";

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = "lux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3d8EQ7GzufZvMfjHbVMdpuGE+vPdSir4diSnB29v0sw=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-RCZzcycUKqJgwBZZQBD1UEZCZCitpiqNpD51oKm6IvI=";
  doCheck = false; # require network

  postInstall = ''
    wrapProgram $out/bin/lux \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/iawia002/lux/app.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    changelog = "https://github.com/iawia002/lux/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ miniharinn ];
    mainProgram = "lux";
  };
})
