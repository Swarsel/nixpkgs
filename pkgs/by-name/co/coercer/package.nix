{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "coercer";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "p0dalirius";
    repo = "Coercer";
    tag = finalAttrs.version;
    hash = "sha256-WeaKToKYIB+jjTNIQvAUQQNb25TsNWALYZwIZuBjkPE=";
  };

  # this file runs into issues on case-insensitive filesystems
  # ValueError: Both <...>/coercer and <...>/coercer.py exist
  postPatch = ''
    rm Coercer.py
  '';

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    impacket
    xlsxwriter
  ];

  pyproject = true;
  pythonImportsCheck = [ "coercer" ];
  pythonRelaxDeps = [ "impacket" ];

  meta = {
    description = "Tool to automatically coerce a Windows server";
    homepage = "https://github.com/p0dalirius/Coercer";
    changelog = "https://github.com/p0dalirius/Coercer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "coercer";
  };
})
