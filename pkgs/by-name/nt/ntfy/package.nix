{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  writableTmpDirAsHomeHook,
  withDbus ? stdenv.hostPlatform.isLinux,
  withEmoji ? true,
  withMatrix ? true,
  withPid ? true,
  withSlack ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ntfy";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "dschep";
    repo = "ntfy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EIhoZ2tFJQOc5PyRCazwRhldFxQb65y6h+vYPwV7ReE=";
  };

  postPatch = ''
    # We disable the Darwin specific things because it relies on pyobjc, which we don't have.
    substituteInPlace setup.py \
      --replace-fail "':sys_platform == \"darwin\"'" "'darwin'"
  '';

  nativeCheckInputs = with python3Packages; [
    mock
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    (
      [
        requests
        ruamel-yaml
        appdirs
        ntfy-webpush
      ]
      ++ lib.optionals withMatrix [
        matrix-client
      ]
      ++ lib.optionals withSlack [
        slack-sdk
      ]
      ++ lib.optionals withEmoji [
        emoji
      ]
      ++ lib.optionals withPid [
        psutil
      ]
      ++ lib.optionals withDbus [
        dbus-python
      ]
    );

  disabledTestPaths = [
    "tests/test_xmpp.py"
  ];

  disabledTests = [
    # AssertionError: {'backends': ['default']} != {}
    "test_default_config"

    # sleekxmpp was deprecated in favor of slixmpp
    "test_xmpp"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ntfy" ];

  meta = {
    description = "Utility for sending notifications, on demand and when commands finish";
    homepage = "https://ntfy.readthedocs.io/en/latest/";
    changelog = "https://github.com/dschep/ntfy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kamilchm ];
    mainProgram = "ntfy";
  };
})
