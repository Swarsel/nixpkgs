{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  lxml,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "xpath-expressions";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "orf";
    repo = "xpath-expressions";
    rev = "v${version}";
    hash = "sha256-UAzDXrz1Tr9/OOjKAg/5Std9Qlrnizei8/3XL3hMSFA=";
  };

  patches = [
    # https://github.com/orf/xpath-expressions/pull/4
    (fetchpatch {
      hash = "sha256-IeV6ncJyt/w2s5TPpbM5a3pljNT6Bp5PIiqgTg2iTRA=";
      name = "replace-poetry-with-poetry-core.patch";
      url = "https://github.com/orf/xpath-expressions/commit/3c5900fd6b2d08dd9468707f35ab42072cf75bd3.patch";
    })
  ];

  nativeBuildInputs = [ poetry-core ];

  nativeCheckInputs = [
    lxml
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "xpath" ];

  meta = {
    description = "Python module to handle XPath expressions";
    homepage = "https://github.com/orf/xpath-expressions";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
