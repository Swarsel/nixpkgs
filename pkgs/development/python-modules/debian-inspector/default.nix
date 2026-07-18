{
  lib,
  attrs,
  buildPythonPackage,
  chardet,
  commoncode,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "debian-inspector";
  version = "31.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-uyFsYrb7D9cM1OQzkIERX0oV711uI/TEKF6t67z8egU=";
    pname = "debian_inspector";
  };

  nativeCheckInputs = [
    commoncode
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    chardet
    attrs
  ];

  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "debian_inspector" ];

  meta = {
    description = "Utilities to parse Debian package, copyright and control files";
    homepage = "https://github.com/nexB/debian-inspector";
    changelog = "https://github.com/aboutcode-org/debian-inspector/blob/v${version}/CHANGELOG.rst";

    license = with lib.licenses; [
      asl20
      bsd3
      mit
    ];

    maintainers = [ ];
  };
}
