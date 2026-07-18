{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pbr,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "git-url-parse";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "coala";
    repo = "git-url-parse";
    tag = finalAttrs.version;
    hash = "sha256-+0V/C3wE02ppdDGn7iqdvmgsUwTR7THUakUilvkzoYg=";
  };

  # Manually set version because prb wants to get it from the git
  # upstream repository (and we are installing from tarball instead)
  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ pbr ];
  pyproject = true;
  pythonImportsCheck = [ "giturlparse" ];

  meta = {
    description = "Simple GIT URL parser";
    homepage = "https://github.com/coala/git-url-parse";
    changelog = "https://github.com/coala/git-url-parse/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
