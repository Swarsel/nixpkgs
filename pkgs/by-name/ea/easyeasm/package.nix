{
  lib,
  fetchFromGitHub,
  alterx,
  amass,
  buildGoModule,
  dnsx,
  httpx,
  makeWrapper,
  subfinder,
}:

buildGoModule (finalAttrs: {
  pname = "easyeasm";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "g0ldencybersec";
    repo = "EasyEASM";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/PhoH+5k63rJL1N3V3IL1TP1oacsBfGfVw/OueN9j8M=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";

  postFixup = ''
    wrapProgram $out/bin/easyeasm \
      --prefix PATH : "${
        lib.makeBinPath [
          amass
          alterx
          subfinder
          dnsx
          httpx
        ]
      }"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Attack surface management tool";
    homepage = "https://github.com/g0ldencybersec/EasyEASM";
    changelog = "https://github.com/g0ldencybersec/EasyEASM/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "easyeasm";
  };
})
