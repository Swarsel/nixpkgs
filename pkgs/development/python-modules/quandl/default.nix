{
  lib,
  buildPythonPackage,
  factory-boy,
  faker,
  fetchPypi,
  httpretty,
  inflection,
  jsondate,
  mock,
  more-itertools,
  numpy,
  pandas,
  parameterized,
  pytestCheckHook,
  python-dateutil,
  requests,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "quandl";
  version = "3.7.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-bguC+8eGFhCzV3xTlyd8QiDgZe7g/tTkbNa2AhZVtkw=";
    pname = "Quandl";
  };

  patches = [ ./pandas2-datetime-removal.patch ];

  propagatedBuildInputs = [
    pandas
    numpy
    requests
    inflection
    python-dateutil
    six
    more-itertools
  ];

  nativeCheckInputs = [
    factory-boy
    faker
    httpretty
    jsondate
    mock
    parameterized
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "quandl" ];

  meta = {
    description = "Quandl Python client library";
    homepage = "https://github.com/quandl/quandl-python";
    changelog = "https://github.com/quandl/quandl-python/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ilya-kolpakov ];
  };
})
