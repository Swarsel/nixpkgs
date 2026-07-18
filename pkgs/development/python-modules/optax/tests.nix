{
  buildPythonPackage,
  dm-haiku,
  flax,
  optax,
  pytest-xdist,
  pytestCheckHook,
  tensorflow,
  tensorflow-datasets,
}:

buildPythonPackage {
  inherit (optax) version;
  pname = "optax-tests";
  src = optax.testsout;

  nativeCheckInputs = [
    dm-haiku
    pytest-xdist
    pytestCheckHook
    tensorflow
    tensorflow-datasets
    flax
  ];

  disabledTestPaths = [
    # See https://github.com/deepmind/optax/issues/323
    "examples/lookahead_mnist_test.py"
  ];

  dontBuild = true;
  dontInstall = true;
  format = "setuptools";
}
