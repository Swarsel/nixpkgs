{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  packaging,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "deprecation";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1zqqjlgmhgkpzg9ss5ki8wamxl83xn51fs6gn2a8cxsx9vkbvcvj";
  };

  patches = [
    # fixes for python 3.10 test suite
    (fetchpatch {
      hash = "sha256-/5zr2V1s5ULUZnbLXsgyHxZH4m7/a27QYuqQt2Savc8=";
      includes = [ "tests/test_deprecation.py" ];
      url = "https://github.com/briancurtin/deprecation/pull/57/commits/e13e23068cb8d653a02a434a159e8b0b7226ffd6.patch";
    })
  ];

  propagatedBuildInputs = [ packaging ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Library to handle automated deprecations";
    homepage = "https://deprecation.readthedocs.io/";
    license = lib.licenses.asl20;
  };
}
