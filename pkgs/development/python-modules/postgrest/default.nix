{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  httpx,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  strenum,
  unasync,
  uv-build,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "postgrest";
  version = "2.29.0";

  src = fetchFromGitHub {
    owner = "supabase";
    repo = "supabase-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LaSlAYFvx/HHdfmc9J+KScVQ9JFGS98Yfihzn8F7t3g=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.8.3,<0.9.0' 'uv_build>=0.8.3'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    unasync
  ];

  build-system = [ uv-build ];

  dependencies = [
    httpx
    deprecation
    pydantic
    strenum
    yarl
  ]
  ++ httpx.optional-dependencies.http2;

  disabledTestPaths = [
    "tests/_sync/"
    "tests/_async/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "postgrest" ];
  sourceRoot = "${finalAttrs.src.name}/src/postgrest";

  meta = {
    description = "Client library for Supabase Functions";
    homepage = "https://github.com/supabase/supabase-py";
    changelog = "https://github.com/supabase/supabase-py/blob/v${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ macbucheron ];
  };
})
