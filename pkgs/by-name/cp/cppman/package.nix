{
  lib,
  fetchFromGitHub,
  groff,
  nix-update-script,
  python3Packages,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cppman";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "aitjcize";
    repo = "cppman";
    tag = finalAttrs.version;
    hash = "sha256-iPJR4XAjNrBhFHZVOATPi3WwTC1/Y6HK3qmKLqbaK98=";
  };

  # bs4 is merely a dummy package and can be safely removed
  # Ideally, its version would also stay fixed.
  postPatch = ''
    substituteInPlace requirements.txt \
      --replace-fail "bs4==0.0.2" ""
  '';

  nativeCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [
    setuptools
    distutils
  ];

  dependencies = [
    python3Packages.beautifulsoup4
    python3Packages.html5lib
    python3Packages.lxml
    python3Packages.six
    python3Packages.soupsieve
    python3Packages.typing-extensions
    python3Packages.webencodings
    groff
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cppman"
  ];

  # cppman pins all dependency versions via requirements.txt as install_requires
  pythonRelaxDeps = true;
  # Writable $HOME is required for `cppman --version` to work
  versionCheckKeepEnvironment = "HOME";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal viewer for C++ 98/11/14 manual pages";
    homepage = "https://github.com/aitjcize/cppman";
    changelog = "https://github.com/aitjcize/cppman/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ryan4yin ];
    mainProgram = "cppman";
  };
})
