{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  hatch-vcs,
  hatchling,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "json-schema-to-pydantic";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "richard-gyiko";
    repo = "json-schema-to-pydantic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9T7ScIf5jJBbldNwLHEchrctr3V4LmqxNGhor6QIzO4=";
  };

  patches = [
    # Pull test fixes for Pydantic 2.13+ from https://github.com/richard-gyiko/json-schema-to-pydantic/pull/46
    (fetchpatch {
      hash = "sha256-+dDFF/eloYuc+ANTjlr9tvI5ycX21o8G1xJOjGlrmTg=";
      name = "pydantic-2.13-test-compat.patch";
      url = "https://github.com/richard-gyiko/json-schema-to-pydantic/commit/acfacd19f282011cfb96b8901d72867a39f57bff.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ pydantic ];
  pyproject = true;
  pythonImportsCheck = [ "json_schema_to_pydantic" ];

  meta = {
    description = "Generates Pydantic v2 models from JSON Schema definitions";
    homepage = "https://github.com/richard-gyiko/json-schema-to-pydantic";
    changelog = "https://github.com/richard-gyiko/json-schema-to-pydantic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aos ];
  };
})
