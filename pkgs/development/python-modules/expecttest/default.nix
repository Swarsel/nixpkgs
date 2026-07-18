{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "expecttest";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "expecttest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/BMaQD3ZgYiprRYZ/fIlW7mStyFGzsjqup62tegBP7Y=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "expecttest" ];

  meta = {
    description = ''EZ Yang "golden" tests (testing against a reference implementation)'';
    homepage = "https://github.com/pytorch/expecttest";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.SomeoneSerge ];
    platforms = lib.platforms.unix;
  };
})
