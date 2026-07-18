{
  lib,
  fetchFromGitHub,
  asciidoctor,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "webcat";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rumpelsepp";
    repo = "webcat";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JyZHH8JgS3uoNVicx1wj0SAzlrXyTrpwIBZuok6buRw=";
  };

  nativeBuildInputs = [
    asciidoctor
    installShellFiles
  ];

  vendorHash = "sha256-duVp/obT+5M4Dl3BAdSgRaP3+LKmS0y51loMMdoGysw=";

  postInstall = ''
    make -C man man
    installManPage man/webcat.1
  '';

  meta = {
    description = "Lightweight swiss army knife for websockets";
    homepage = "https://rumpelsepp.org/blog/ssh-through-websocket/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ montag451 ];
    mainProgram = "webcat";
  };
})
