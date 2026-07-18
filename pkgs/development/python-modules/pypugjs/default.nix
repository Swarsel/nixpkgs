{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  django,
  jinja2,
  mako,
  poetry-core,
  pyramid,
  pyramid-mako,
  pytestCheckHook,
  six,
  tornado,
}:

buildPythonPackage rec {
  pname = "pypugjs";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "kakulukia";
    repo = "pypugjs";
    tag = "v${version}";
    hash = "sha256-7w+YTNBxDQ8UZdvX3JfBQc9HQR3zNTGsEp+OR/LWcmU=";
  };

  nativeCheckInputs = [
    django
    jinja2
    mako
    tornado
    pyramid
    pyramid-mako
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    six
    charset-normalizer
  ];

  pyproject = true;
  pytestFlags = [ "pypugjs/testsuite" ];

  pythonImportsCheck = [
    "pypugjs"
  ];

  pythonRelaxDeps = [
    "charset-normalizer"
  ];

  meta = {
    description = "PugJS syntax template adapter for Django, Jinja2, Mako and Tornado templates";
    homepage = "https://github.com/kakulukia/pypugjs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lopsided98 ];
    mainProgram = "pypugjs";
  };
}
