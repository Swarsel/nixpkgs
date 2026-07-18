{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "apkid";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "rednaga";
    repo = "APKiD";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sX9HQUW+oB7vmlz3I0I/NwqOVGqR8j1WZXtDCISMkxY=";
  };

  postPatch = ''
    # We have dex support enabled in yara-python
    substituteInPlace setup.py \
      --replace "yara-python-dex>=1.0.1" "yara-python"
  '';

  preBuild = ''
    # Prepare the YARA rules
    ${python3.interpreter} prep-release.py
  '';

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [ yara-python ];
  pyproject = true;
  pythonImportsCheck = [ "apkid" ];

  meta = {
    description = "Android Application Identifier";
    homepage = "https://github.com/rednaga/APKiD";
    changelog = "https://github.com/rednaga/APKiD/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "apkid";
  };
})
