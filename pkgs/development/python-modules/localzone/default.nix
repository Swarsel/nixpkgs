{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "localzone";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "ags-slc";
    repo = "localzone";
    tag = "v${version}";
    hash = "sha256-quAo5w4Oxu9Hu96inu3vuiQ9GZMLpq0M8Vj67IPYcbE=";
  };

  postPatch = ''
    # Fix tests with dnspython 2.8.0
    # https://github.com/ags-slc/localzone/pull/6
    substituteInPlace tests/test_models.py \
      --replace-fail 'raises((AttributeError, DNSSyntaxError))' 'raises((AttributeError, DNSSyntaxError, ValueError))'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ dnspython ];
  pyproject = true;
  pythonImportsCheck = [ "localzone" ];

  meta = {
    description = "Simple DNS library for managing zone files";
    homepage = "https://localzone.iomaestro.com";
    changelog = "https://github.com/ags-slc/localzone/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
  };
}
