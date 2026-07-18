{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  # build-system
  pbr,
  # tests
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "munch";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "Infinidat";
    repo = "munch";
    tag = version;
    hash = "sha256-p7DvOGRhkCmtJ32EfttyKXGGmO5kfb2bQGqok/RJtU8=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-n/uBAP7pnlGZcnDuxdMKWgAEdG9gWeGoLWB97T1KloY=";
      # python3.13 compat
      url = "https://github.com/Infinidat/munch/commit/84651ee872f9ea6dbaed986fd3818202933a8b50.patch";
    })
  ];

  nativeBuildInputs = [
    pbr
    setuptools
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  pyproject = true;

  meta = {
    description = "Dot-accessible dictionary (a la JavaScript objects)";
    homepage = "https://github.com/Infinidat/munch";
    license = lib.licenses.mit;
  };
}
