{
  lib,
  fetchFromGitHub,
  buildGoModule,
  runtimeShell,
}:

buildGoModule (finalAttrs: {
  pname = "hivemind";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "DarthSim";
    repo = "hivemind";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YUR9OwRuH1xSPs8iTsSIjLCt2TyYH357IAYULGTyYUc=";
  };

  postPatch = ''
    substituteInPlace process.go --replace \"/bin/sh\" \"${runtimeShell}\"
  '';

  vendorHash = "sha256-KweFhT8Zueg45Q/vw3kNET35hB+0WbUPfz0FYaAiIA8=";

  meta = {
    description = "Process manager for Procfile-based applications";
    homepage = "https://github.com/DarthSim/";
    license = with lib.licenses; [ mit ];
    maintainers = [ lib.maintainers.sveitser ];
    mainProgram = "hivemind";
  };
})
