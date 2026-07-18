{
  lib,
  fetchFromGitHub,
  agate,
  buildPythonPackage,
  dbf,
  dbfread,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "agate-dbf";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "wireservice";
    repo = "agate-dbf";
    tag = finalAttrs.version;
    hash = "sha256-z68nYig+Z1/C+ys7HmjljdnHhUTqH58iBSbqnLnLFs4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    agate
    dbfread
  ];

  pyproject = true;

  meta = {
    description = "Adds read support for dbf files to agate";
    homepage = "https://github.com/wireservice/agate-dbf";
    changelog = "https://github.com/wireservice/agate-dbf/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
})
