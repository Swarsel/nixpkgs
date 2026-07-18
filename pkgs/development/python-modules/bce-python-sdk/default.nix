{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  pycryptodome,
  setuptools,
  six,
}:

let
  version = "0.9.63";
in
buildPythonPackage {
  inherit version;
  pname = "bce-python-sdk";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DIC8OsEooKFEuuO43/Hzl/QsMLNvdnfjo52N+Od7EIg=";
    pname = "bce_python_sdk";
  };

  patches = [
    # From https://github.com/baidubce/bce-sdk-python/pull/15 . Upstream
    # doesn't seem to be responsive, the patch there doesn't apply cleanly on
    # this version, so a vendored patch was produced by running:
    #
    #   git show -- setup.py baidubce
    #
    # in the Git checkout of the PR above.
    ./no-future.patch
  ];

  build-system = [ setuptools ];

  dependencies = [
    pycryptodome
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "baidubce" ];

  meta = {
    description = "Baidu Cloud Engine SDK for python";
    homepage = "https://github.com/baidubce/bce-sdk-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kyehn ];
  };
}
