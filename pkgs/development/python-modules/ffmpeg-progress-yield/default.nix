{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg,
  procps,
  pytest-asyncio,
  pytestCheckHook,
  tqdm,
  uv-build,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "ffmpeg-progress-yield";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "slhck";
    repo = "ffmpeg-progress-yield";
    tag = "v${version}";
    hash = "sha256-OEE23gzPYcjKjrar+aV2zZuZyhrvqkYPhnWC3GzefUI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    ffmpeg
    procps
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = [ uv-build ];

  dependencies = [
    tqdm
  ];

  disabledTests = lib.optional stdenv.hostPlatform.isDarwin [
    # cannot access /usr/bin/pgrep from the sandbox
    "test_context_manager"
    "test_context_manager_with_exception"
    "test_automatic_cleanup_on_exception"
    "test_async_context_manager"
    "test_async_context_manager_with_exception"
    "test_async_automatic_cleanup_on_exception"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ffmpeg_progress_yield" ];

  meta = {
    description = "Run an ffmpeg command with progress";
    homepage = "https://github.com/slhck/ffmpeg-progress-yield";
    changelog = "https://github.com/slhck/ffmpeg-progress-yield/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
    mainProgram = "ffmpeg-progress-yield";
  };
}
