{
  lib,
  stdenv,
  buildPythonPackage,
  # Runtime dependencies
  decorator,
  fetchPypi,
  ipython-pygments-lexers,
  jedi,
  # Optional dependencies
  matplotlib,
  matplotlib-inline,
  pexpect,
  # Test dependencies
  pickleshare,
  prompt-toolkit,
  psutil,
  pygments,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  # Reverse dependency
  sage,
  # Build dependencies
  setuptools,
  stack-data,
  testpath,
  traitlets,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "ipython";
  version = "9.14.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-byf/Dx2eoFDgVR9xVovEs02KuleejxEcW0F19ErGtKo=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeCheckInputs = [
    pickleshare
    pytest-asyncio
    pytestCheckHook
    testpath
  ];

  preCheck = ''
    export HOME=$TMPDIR

    # doctests try to fetch an image from the internet
    substituteInPlace pyproject.toml \
      --replace-fail '"--ipdoctest-modules",' '"--ipdoctest-modules", "--ignore=IPython/core/display.py",'
  '';

  build-system = [ setuptools ];

  dependencies = [
    decorator
    ipython-pygments-lexers
    jedi
    matplotlib-inline
    pexpect
    prompt-toolkit
    psutil
    pygments
    stack-data
    traitlets
  ]
  ++ lib.optionals (pythonOlder "3.12") [ typing-extensions ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isDarwin) [
    # FileNotFoundError: [Errno 2] No such file or directory: 'pbpaste'
    "test_clipboard_get"
  ];

  optional-dependencies = {
    matplotlib = [ matplotlib ];
  };

  pyproject = true;
  pythonImportsCheck = [ "IPython" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "IPython: Productive Interactive Computing";
    homepage = "https://ipython.readthedocs.io/en/stable/";
    changelog = "https://github.com/ipython/ipython/blob/${finalAttrs.version}/docs/source/whatsnew/version${lib.versions.major finalAttrs.version}.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bjornfor ];
    downloadPage = "https://github.com/ipython/ipython/";
    teams = [ lib.teams.jupyter ];
  };
})
