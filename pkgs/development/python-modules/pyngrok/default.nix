{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyngrok";
  version = "8.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-O1OD7H3EZGrA0EZDXrWMbNHLyaytcObe4BKwXcJbBwo=";
  };

  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "pyngrok" ];

  meta = {
    description = "Python wrapper for ngrok";
    homepage = "https://github.com/alexdlaird/pyngrok";
    changelog = "https://github.com/alexdlaird/pyngrok/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
})
