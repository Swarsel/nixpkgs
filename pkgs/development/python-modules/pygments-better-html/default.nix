{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pygments,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygments-better-html";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "Kwpolska";
    repo = "pygments_better_html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7vX/xm1lb89YLuDJmgdDCg+/UHinQAchi8OaF9TXRJA=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} demo.py
    runHook postCheck
  '';

  build-system = [ flit-core ];
  dependencies = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "pygments_better_html" ];

  meta = {
    description = "Improved line numbering for Pygments’ HTML formatter";
    homepage = "https://github.com/Kwpolska/pygments_better_html";
    changelog = "https://github.com/Kwpolska/pygments_better_html/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
