{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  pythonOlder,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "para";
  version = "0.0.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-RsMjKunY6p2IbP0IzdESiSICvthkX0C2JVWXukz+8hc=";
  };

  doCheck =
    #  AttributeError: Can't get local object 'test_output_queue_size.<locals>.get_the_a'
    (!stdenv.hostPlatform.isDarwin)
    # _pickle.PicklingError: Can't pickle local object <function test_map.<locals>.get_the_a at 0x7ffff5689fe0>
    && (pythonOlder "3.14");

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "para" ];

  meta = {
    description = "Set utilities that ake advantage of python's 'multiprocessing' module to distribute CPU-intensive tasks";
    homepage = "https://pypi.org/project/para";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
