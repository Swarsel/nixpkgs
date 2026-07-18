{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  httpx,
  pydantic,
  pyiceberg,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  python-dotenv,
  uv-build,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "storage3";
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
    python-dotenv
  ];

  build-system = [ uv-build ];

  dependencies = [
    httpx
    pydantic
    yarl
    pyiceberg
    deprecation
  ]
  ++ httpx.optional-dependencies.http2;

  disabledTestPaths = [
    "tests/_sync/"
    "tests/_async/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "storage3" ];
  sourceRoot = "${finalAttrs.src.name}/src/storage";

  meta = {
    description = "Client library for Supabase Functions";
    homepage = "https://github.com/supabase/supabase-py";
    changelog = "https://github.com/supabase/supabase-py/blob/v${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      siegema
      macbucheron
    ];
  };
})
