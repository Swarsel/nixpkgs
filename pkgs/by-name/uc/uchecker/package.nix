{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "uchecker";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "cloudlinux";
    repo = "kcare-uchecker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SST143oi0O9PcJbw4nxHwHNY6HkIGi1WMBzveUYVhJs=";
  };

  patches = [
    # Switch to poetry-core, https://github.com/cloudlinux/kcare-uchecker/pull/52
    (fetchpatch {
      hash = "sha256-YPPw6M7MGN8nguAvAwjmz0VEYm0RD98ZkoVIq9SP3sA=";
      name = "switch-poetry-core.patch";
      url = "https://github.com/cloudlinux/kcare-uchecker/commit/d7d5ab75efa6a355b3dd3190c1edbaba8110c885.patch";
    })
  ];

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  nativeCheckInputs = with python3.pkgs; [
    mock
    pytestCheckHook
  ];

  pyproject = true;

  pythonImportsCheck = [
    "uchecker"
  ];

  meta = {
    description = "Simple tool to detect outdated shared libraries";
    homepage = "https://github.com/cloudlinux/kcare-uchecker";
    changelog = "https://github.com/cloudlinux/kcare-uchecker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "uchecker";
  };
})
