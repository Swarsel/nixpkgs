{
  lib,
  fetchFromGitHub,
  # tests
  anthropic,
  # dependencies
  asgiref,
  buildPythonPackage,
  cacert,
  click,
  google-generativeai,
  htmltools,
  langchain-core,
  libsass,
  linkify-it-py,
  markdown-it-py,
  mdit-py-plugins,
  narwhals,
  ollama,
  openai,
  orjson,
  packaging,
  pandas,
  platformdirs,
  polars,
  prompt-toolkit,
  pytest-asyncio,
  pytest-playwright,
  pytest-rerunfailures,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  python-multipart,
  questionary,
  # build-system
  setuptools,
  setuptools-scm,
  shinychat,
  starlette,
  typing-extensions,
  uvicorn,
  watchfiles,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "shiny";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "py-shiny";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8iqnm1SQ4h0GuwqKDzL6qEdbw0gJ2a5Aqg5WJgbaKBI=";
  };

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs = [
    anthropic
    google-generativeai
    langchain-core
    ollama
    openai
    pandas
    polars
    pytest-asyncio
    pytest-playwright
    pytest-rerunfailures
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asgiref
    click
    htmltools
    linkify-it-py
    markdown-it-py
    mdit-py-plugins
    narwhals
    orjson
    packaging
    platformdirs
    prompt-toolkit
    python-multipart
    questionary
    setuptools
    shinychat
    starlette
    typing-extensions
    uvicorn
    watchfiles
    websockets
  ];

  disabledTests = [
    # Requires unpackaged brand-yml
    "test_theme_from_brand_base_case_compiles"
    # ValueError: A tokenizer is required to impose `token_limits` on messages
    "test_chat_message_trimming"

    # Snapshot tests fail with AssertionError
    "test_toast_header_icon_renders_in_header"
    "test_toast_header_icon_with_status_and_title"
    "test_toast_icon_renders_in_body_with_header"
    "test_toast_icon_renders_in_body_without_header"
    "test_toast_icon_works_with_closable_button_in_body"
    "test_toast_with_both_header_icon_and_body_icon"
    "test_toast_with_custom_tag_header"
  ];

  optional-dependencies = {
    theme = [
      libsass
      # FIXME package brand-yml
    ];
  };

  pyproject = true;

  pytestFlags = [
    # ERROR: 'fixture' is not a valid asyncio_default_fixture_loop_scope.
    # Valid scopes are: function, class, module, package, session.
    # https://github.com/pytest-dev/pytest-asyncio/issues/924
    "-o asyncio_mode=auto"
    "-o asyncio_default_fixture_loop_scope=function"
  ];

  pythonImportsCheck = [ "shiny" ];

  meta = {
    description = "Build fast, beautiful web applications in Python";
    homepage = "https://shiny.posit.co/py";
    changelog = "https://github.com/posit-dev/py-shiny/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
