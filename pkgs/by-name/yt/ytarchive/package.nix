{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg-headless,
  makeBinaryWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "ytarchive";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Kethsar";
    repo = "ytarchive";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Y1frd7iJJuNFvLL/C1Y+RrqYC/1LF7P3J9rkPAThp9c=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-hVAiWJKdDQB+6UlARFdjVATCMiGrEK2US62KAxCquvU=";

  postInstall = ''
    wrapProgram $out/bin/ytarchive --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Commit=-${finalAttrs.src.rev}"
  ];

  meta = {
    description = "Garbage Youtube livestream downloader";
    homepage = "https://github.com/Kethsar/ytarchive";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "ytarchive";
  };
})
