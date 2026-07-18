{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dlinfo";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "fphammerle";
    repo = "python-dlinfo";
    tag = "v${version}";
    hash = "sha256-W9WfXU5eIMQQImzRgTJS0KL4IZfRtLrK8TYmdEc0VLI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "dlinfo" ];

  meta = {
    description = "Python wrapper for libc's dlinfo and dyld_find on Mac";
    homepage = "https://github.com/fphammerle/python-dlinfo";
    changelog = "https://github.com/fphammerle/python-dlinfo/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
