{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dateparser,
  orjson,
  pydantic,
  ua-parser,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "lookyloo-models";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "Lookyloo";
    repo = "lookyloo-models";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jqbG8wYUePYnQqqJEek9zFnuuGLarJvwzri19lvRUbY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.11,<0.12" "uv_build"
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ uv-build ];

  dependencies = [
    dateparser
    orjson
    pydantic
    ua-parser
  ];

  pyproject = true;
  pythonImportsCheck = [ "lookyloo_models" ];
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Set of models representing data passed around across the toolchain";
    homepage = "https://github.com/Lookyloo/lookyloo-models";
    # https://github.com/Lookyloo/lookyloo-models/issues/2
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ fab ];
  };
})
