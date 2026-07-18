{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyhumps";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "nficano";
    repo = "humps";
    tag = "v${version}";
    hash = "sha256-PvfjW56UVCcjd2jJiQW/goVJ1BC8xQ973xuZ6izwclw=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-5+ZKEqydN+SF2ihWUf7B8TBY2DK7xFIU/WRDS3+pD0k=";
      name = "revert_decamelize_ignore_numeric_characters.patch";
      revert = true;
      url = "https://github.com/nficano/humps/commit/661828b8b3e6fac15236b14ffbdf038aef516d4c.patch";
    })
  ];

  nativeBuildInputs = [ poetry-core ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "humps" ];

  meta = {
    description = "Module to convert strings (and dictionary keys) between snake case, camel case and pascal case";
    homepage = "https://github.com/nficano/humps";
    license = with lib.licenses; [ unlicense ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
