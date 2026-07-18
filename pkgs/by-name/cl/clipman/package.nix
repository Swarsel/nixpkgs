{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  wl-clipboard,
}:

buildGoModule (finalAttrs: {
  pname = "clipman";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "clipman";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fAiXivLXpxezvMUKv0HfDvzSN60G4RFfgi6/fO0C1p8=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = "sha256-QD/ucnIqPHgKaYRmBO4fwDVqC7kKlYmBaZp3XBWudy0=";
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/clipman \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard ]}
    installManPage docs/*.1
  '';

  meta = {
    description = "Simple clipboard manager for Wayland";
    homepage = "https://github.com/chmouel/clipman";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.linux;
    mainProgram = "clipman";
  };
})
