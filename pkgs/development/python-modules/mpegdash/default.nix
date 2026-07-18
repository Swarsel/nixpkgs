{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "mpegdash";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "sangwonl";
    repo = "python-mpegdash";
    rev = version;
    hash = "sha256-WrsTxI6zdPCvzU4bW41kuPpR6B1DcDRUFDbAb9JZnK8=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # requires network access
    "test_xml2mpd_from_url"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mpegdash" ];

  meta = {
    description = "MPEG-DASH MPD(Media Presentation Description) Parser";
    homepage = "https://github.com/sangwonl/python-mpegdash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drawbu ];
  };
}
