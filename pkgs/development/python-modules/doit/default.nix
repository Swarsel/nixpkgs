{
  lib,
  stdenv,
  buildPythonPackage,
  cloudpickle,
  configclass,
  doit-py,
  fetchPypi,
  importlib-metadata,
  isPy3k,
  macfsevents,
  mergedict,
  mock,
  pyflakes,
  pyinotify,
  pytestCheckHook,
  setuptools,
  toml,
}:

let
  doit = buildPythonPackage rec {
    pname = "doit";
    version = "0.37.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-08cuDkao+h3avqj4MHYkAt7gkMrzPDDCKVrHAQ248Jw=";
    };

    propagatedBuildInputs = [
      cloudpickle
      importlib-metadata
      toml
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux pyinotify
    ++ lib.optional stdenv.hostPlatform.isDarwin macfsevents;

    # escape infinite recursion with doit-py
    doCheck = false;

    nativeCheckInputs = [
      configclass
      doit-py
      mergedict
      mock
      pyflakes
      pytestCheckHook
    ];

    build-system = [
      setuptools
    ];

    disabled = !isPy3k;
    pyproject = true;
    pythonImportsCheck = [ "doit" ];

    passthru.tests = {
      # hangs on darwin
      check = doit.overridePythonAttrs (_: {
        doCheck = !stdenv.hostPlatform.isDarwin;
      });
    };

    meta = {
      description = "Task management & automation tool";

      longDescription = ''
        doit is a modern open-source build-tool written in python
        designed to be simple to use and flexible to deal with complex
        work-flows. It is specially suitable for building and managing
        custom work-flows where there is no out-of-the-box solution
        available.
      '';

      homepage = "https://pydoit.org/";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ pSub ];
      mainProgram = "doit";
    };
  };
in
doit
