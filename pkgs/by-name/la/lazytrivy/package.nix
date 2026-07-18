{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nix-update-script,
  trivy,
}:

buildGoModule (finalAttrs: {
  pname = "lazytrivy";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "owenrumney";
    repo = "lazytrivy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0VWmsZKp0IEQ93AuMoYXN8pF0G3fwaP7Lzh3JsN2CtU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-HKD7vpQAw3G4uMLUMhbv6tsFCOxfp62Phynun4HkFrg=";
  env.GOEXPERIMENT = "jsonv2";

  postFixup = ''
    wrapProgram $out/bin/lazytrivy \
      --prefix PATH : ${
        lib.makeBinPath [
          trivy
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI to do vulnerability scanning using trivy";
    homepage = "https://github.com/owenrumney/lazytrivy";
    changelog = "https://github.com/owenrumney/lazytrivy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kpbaks ];
    mainProgram = "lazytrivy";
  };
})
