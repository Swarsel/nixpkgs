{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mustache-go";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "cbroglie";
    repo = "mustache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A7LIkidhpFmhIjiDu9KdmSIdqFNsV3N8J2QEo7yT+DE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-FYdsLcW6FYxSgixZ5US9cBPABOAVwidC3ejUNbs1lbA=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Mustache template language in Go";
    homepage = "https://github.com/cbroglie/mustache";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ Zimmi48 ];
    mainProgram = "mustache";
  };
})
