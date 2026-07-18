{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  orjson,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "drf-orjson-renderer";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "brianjbuck";
    repo = "drf_orjson_renderer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PMVb+BtTl25BsftQhYlKdEhGhhH3HTlROVYsm+7PBjY=";
  };

  doCheck = false; # Tests are broken upstream (https://github.com/brianjbuck/drf_orjson_renderer/pull/26)
  build-system = [ setuptools ];

  dependencies = [
    django
    djangorestframework
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "drf_orjson_renderer" ];

  meta = {
    description = "JSON renderer and parser for Django Rest Framework using the orjson library";
    homepage = "https://github.com/brianjbuck/drf_orjson_renderer";
    changelog = "https://github.com/brianjbuck/drf_orjson_renderer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jvanbruegge ];
  };
})
