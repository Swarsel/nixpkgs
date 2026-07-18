{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  logistro,
  # build-system
  setuptools,
  simplejson,
}:

buildPythonPackage (finalAttrs: {
  pname = "choreographer";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "plotly";
    repo = "choreographer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WjAE3UlUCiXK5DxwmZvehQQaoJRkgEE8rNJQdAyOM4Q=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools-git-versioning"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${finalAttrs.version}"'
  '';

  # Tests require running chrome
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    logistro
    simplejson
  ];

  pyproject = true;
  pythonImportsCheck = [ "choreographer" ];

  meta = {
    description = "Devtools Protocol implementation for chrome";
    homepage = "https://github.com/plotly/choreographer";
    changelog = "https://github.com/plotly/choreographer/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
