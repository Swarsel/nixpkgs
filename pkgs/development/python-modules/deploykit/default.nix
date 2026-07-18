{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildPythonPackage,
  hatchling,
  openssh,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "deploykit";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "numtide";
    repo = "deploykit";
    rev = version;
    hash = "sha256-RONE/oJdNmVjLYdJWDTzyXnmStkLIx92GsydaYYG5O4=";
  };

  nativeCheckInputs = [
    bash
    openssh
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [ "test_ssh" ];
  pyproject = true;
  # don't swallow stdout/stderr
  pytestFlags = [ "-s" ];
  pythonImportsCheck = [ "deploykit" ];

  meta = {
    description = "Execute commands remote via ssh and locally in parallel with python";
    homepage = "https://github.com/numtide/deploykit";
    changelog = "https://github.com/numtide/deploykit/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mic92
      zowoq
    ];

    platforms = lib.platforms.unix;
  };
}
