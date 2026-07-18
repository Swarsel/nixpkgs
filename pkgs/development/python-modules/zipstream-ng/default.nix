{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "zipstream-ng";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "pR0Ps";
    repo = "zipstream-ng";
    tag = "v${version}";
    hash = "sha256-1MSnabckpAwV/NmD5wKxF7k7hwve6fBiCPyw7skxdlM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "zipstream" ];

  meta = {
    description = "Library to generate streamable zip files";

    longDescription = ''
      A modern and easy to use streamable zip file generator. It can package and stream many files
      and folders on the fly without needing temporary files or excessive memory
    '';

    homepage = "https://github.com/pR0Ps/zipstream-ng";
    changelog = "https://github.com/pR0Ps/zipstream-ng/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ gador ];
    mainProgram = "zipserver";
  };
}
