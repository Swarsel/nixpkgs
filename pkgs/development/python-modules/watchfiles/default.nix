{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  dirty-equals,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
  rustPlatform,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "watchfiles";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "samuelcolvin";
    repo = "watchfiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UlQnCYSNU9H4x31KenSfYExGun94ekrOCwajORemSco=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    dirty-equals
    pytest-mock
    pytest-timeout
    pytestCheckHook
    versionCheckHook
  ];

  preCheck = ''
    rm -rf watchfiles
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-6sxtH7KrwAWukPjLSMAebguPmeAHbC7YHOn1QiRPigs=";
  };

  dependencies = [ anyio ];

  disabledTests = [
    #  BaseExceptionGroup: unhandled errors in a TaskGroup (1 sub-exception)
    "test_awatch_interrupt_raise"
  ];

  pyproject = true;
  pythonImportsCheck = [ "watchfiles" ];

  # Tests need these permissions in order to use the FSEvents API on macOS.
  sandboxProfile = ''
    (allow mach-lookup (global-name "com.apple.FSEvents"))
  '';

  meta = {
    description = "File watching and code reload";
    homepage = "https://watchfiles.helpmanual.io/";
    changelog = "https://github.com/samuelcolvin/watchfiles/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "watchfiles";
  };
})
