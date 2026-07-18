{
  lib,
  fetchFromGitHub,
  kicad,
  python3Packages,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "interactive-html-bom";
  version = "2.11.2";

  src = fetchFromGitHub {
    owner = "openscopeproject";
    repo = "InteractiveHtmlBom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MNwQJAibnAAMvsoTWtFiIhM6TGVUs7B2w6sA4ruXFbc=";
  };

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    cp ${kicad.base}/share/kicad/demos/stickhub/StickHub.kicad_pcb .
    HOME=$(mktemp -d) xvfb-run $out/bin/generate_interactive_bom --no-browser StickHub.kicad_pcb

    runHook postCheck
  '';

  build-system = [ python3Packages.hatchling ];

  dependencies = [
    python3Packages.jsonschema
    python3Packages.wxpython
    python3Packages.kicad
  ];

  pyproject = true;

  meta = {
    description = "Interactive HTML BOM generation for KiCad, EasyEDA, Eagle, Fusion360 and Allegro PCB designer";
    homepage = "https://github.com/openscopeproject/InteractiveHtmlBom/";
    changelog = "https://github.com/openscopeproject/InteractiveHtmlBom/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wuyoli ];
    mainProgram = "generate_interactive_bom";
  };
})
