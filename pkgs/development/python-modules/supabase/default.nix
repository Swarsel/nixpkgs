{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  postgrest,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  python-dotenv,
  realtime,
  storage3,
  supabase-auth,
  supabase-functions,
  uv-build,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "supabase";
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

  nativeBuildInputs = [
    pytestCheckHook
    python-dotenv
    pytest-asyncio
    pytest-cov-stub
  ];

  doCheck = true;
  build-system = [ uv-build ];

  dependencies = [
    realtime
    supabase-auth
    supabase-functions
    postgrest
    httpx
    yarl
    storage3
  ];

  pyproject = true;
  pythonImportsCheck = [ "supabase" ];
  sourceRoot = "${finalAttrs.src.name}/src/supabase";

  meta = {
    description = "Supabase client for Python";
    homepage = "https://github.com/supabase/supabase-py";
    changelog = "https://github.com/supabase/supabase-py/blob/v${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      siegema
      macbucheron
    ];
  };
})
