{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  subprocess4,
}:

buildPythonPackage (finalAttrs: {
  pname = "coq-tools";
  version = "0.0.44";

  src = fetchFromGitHub {
    owner = "JasonGross";
    repo = "coq-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WMxJkLGfMtXu4ZpIuS1wIXMvgJbCMy2eY8qz5+v9LI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ subprocess4 ];
  pyproject = true;
  pythonImportsCheck = [ "coq_tools" ];

  meta = {
    description = "Tools for working with Coq proof assistant";
    homepage = "https://pypi.org/project/coq-tools/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
