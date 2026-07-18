{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fonttools,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "dehinter";
  version = "4.0.0";

  # PyPI source tarballs omit tests, fetch from Github instead
  src = fetchFromGitHub {
    owner = "source-foundry";
    repo = "dehinter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-l988SW6OWKXzJK0WGAJZR/QDFvgnSir+5TwMMvFcOxg=";
  };

  propagatedBuildInputs = [ fonttools ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Utility for removing hinting data from TrueType and OpenType fonts";
    homepage = "https://github.com/source-foundry/dehinter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
    mainProgram = "dehinter";
  };
})
