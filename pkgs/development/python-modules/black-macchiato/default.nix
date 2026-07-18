{
  lib,
  fetchFromGitHub,
  black,
  buildPythonPackage,
  fetchpatch,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "black-macchiato";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "wbolster";
    repo = "black-macchiato";
    rev = finalAttrs.version;
    sha256 = "0lc9w50nlbmlzj44krk7kxcia202fhybbnwfh77xixlc7vb4rayl";
  };

  patches = [
    # fix empty multi-line string test
    (fetchpatch {
      hash = "sha256-3m8U6c+1UCRy/Fkq6lk9LhwrFyE+q3GD2jnMA7N4ZJs=";
      url = "https://github.com/wbolster/black-macchiato/commit/d3243a1c95b5029b3ffa12417f0c587a2ba79bcd.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ black ];
  pyproject = true;
  pythonImportsCheck = [ "black" ];

  meta = {
    description = "This is a small utility built on top of the black Python code formatter to enable formatting of partial files";
    homepage = "https://github.com/wbolster/black-macchiato";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jperras ];
    mainProgram = "black-macchiato";
  };
})
