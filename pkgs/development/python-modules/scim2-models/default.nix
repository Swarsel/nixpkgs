{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  fastapi,
  flask,
  httpx,
  pydantic,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "scim2-models";
  version = "0.6.12";

  src = fetchFromGitHub {
    owner = "python-scim";
    repo = "scim2-models";
    tag = finalAttrs.version;
    hash = "sha256-EYWPz44cVbff/qV/nSwU+RDWhLypUMoCAdZfxpkC9ag=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.9,<0.9.0" "uv_build"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    django
    fastapi
    flask
    httpx
  ];

  build-system = [ uv-build ];
  dependencies = [ pydantic ] ++ pydantic.optional-dependencies.email;
  pyproject = true;
  pythonImportsCheck = [ "scim2_models" ];

  meta = {
    description = "SCIM2 models serialization and validation with pydantic";
    homepage = "https://github.com/python-scim/scim2-models";
    changelog = "https://github.com/python-scim/scim2-models/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ erictapen ];
  };
})
