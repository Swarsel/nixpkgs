{
  lib,
  fetchFromGitHub,
  # for passthru.tests
  asgi-csrf,
  buildPythonPackage,
  connexion,
  fastapi,
  gradio,
  hatchling,
  pytestCheckHook,
  pyyaml,
  starlette,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-multipart";
  version = "0.0.30";

  src = fetchFromGitHub {
    owner = "Kludex";
    repo = "python-multipart";
    tag = finalAttrs.version;
    hash = "sha256-qW/OkOaM+7sN6+mxO5tm6tuDDJ/c703XDNqo6i6YnXo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "python_multipart" ];

  passthru.tests = {
    inherit
      asgi-csrf
      connexion
      fastapi
      gradio
      starlette
      ;
  };

  meta = {
    description = "Streaming multipart parser for Python";
    homepage = "https://github.com/Kludex/python-multipart";
    changelog = "https://github.com/Kludex/python-multipart/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      dotlambda
      ris
    ];
  };
})
