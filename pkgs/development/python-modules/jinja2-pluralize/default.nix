{
  lib,
  buildPythonPackage,
  fetchPypi,
  inflect,
  jinja2,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jinja2-pluralize";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-31wtUBe5tUwKZst5DMqfwIlFg3w9v8MjWJID8f+3PBw=";
    pname = "jinja2_pluralize";
  };

  propagatedBuildInputs = [
    jinja2
    inflect
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "jinja2_pluralize" ];

  meta = {
    description = "Jinja2 pluralize filters";
    homepage = "https://github.com/audreyr/jinja2_pluralize";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dzabraev ];
  };
})
