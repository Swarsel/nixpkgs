{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kernel-hardening-checker";
  version = "0.6.17.1";

  src = fetchFromGitHub {
    owner = "a13xp0p0v";
    repo = "kernel-hardening-checker";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wkRbiXHLtTDYBrxn9ZPxXMmWJiIBI5AImjFo6NVaKRM=";
  };

  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "kernel_hardening_checker" ];

  meta = {
    description = "Tool for checking the security hardening options of the Linux kernel";
    homepage = "https://github.com/a13xp0p0v/kernel-hardening-checker";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ erdnaxe ];
    platforms = lib.platforms.all;
    mainProgram = "kernel-hardening-checker";
  };
})
