{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python,
  setuptools,
}:
let
  table = fetchurl {
    hash = "sha256-r1mRvI/qcOYOGKVzXHJGFdYxc+YlzpcdnWJExaF0Mp0=";
    # See https://github.com/dahlia/iso4217/blob/main/setup.py#L19
    url = "https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml";
  };
in
buildPythonPackage rec {
  pname = "iso4217";
  version = "1.16";

  src = fetchFromGitHub {
    owner = "dahlia";
    repo = "iso4217";
    tag = version;
    hash = "sha256-C7TwGlbTwpcJ0rE7notWzZHthWzXKMPbHq00zMhfHeA=";
  };

  preBuild = ''
    # The table is already downloaded
    export ISO4217_DOWNLOAD=0
    # Copy the table file to satifiy the build process
    cp -r ${table} iso4217/table.xml
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    # Copy the table file
    cp -r ${table} $out/${python.sitePackages}/iso4217/table.xml
  '';

  build-system = [ setuptools ];
  enabledTestPaths = [ "iso4217/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "iso4217" ];

  meta = {
    description = "ISO 4217 currency data package for Python";
    homepage = "https://github.com/dahlia/iso4217";
    license = with lib.licenses; [ publicDomain ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
