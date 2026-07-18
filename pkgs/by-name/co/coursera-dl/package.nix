{
  lib,
  fetchFromGitHub,
  fetchpatch,
  pandoc,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "coursera-dl";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "coursera-dl";
    repo = "coursera-dl";
    tag = finalAttrs.version;
    hash = "sha256-c+ElGIrd4ZhMfWtsNHrHRO3HaRRtEQuGlCSBrvPnbyo=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-e52QPr4XH+HnB49R+nkG0KC9Zf1TbPf92dcP7ts3ih0=";
      url = "https://github.com/coursera-dl/coursera-dl/commit/c8796e567698be166cb15f54e095140c1a9b567e.patch";
    })
    (fetchpatch {
      hash = "sha256-/AKFvBPInSq/lsz+G0jVSl/ukVgCnt66oePAb+66AjI=";
      url = "https://github.com/coursera-dl/coursera-dl/commit/6c221706ba828285ca7a30a08708e63e3891b36f.patch";
    })
    # https://github.com/coursera-dl/coursera-dl/pull/857
    (fetchpatch {
      hash = "sha256-OpW8gqzrMyaE69qH3uGsB5TNQTYaO7pn3uJ7NU5SrcM=";
      name = "python-3.11-compatibility.patch";
      url = "https://github.com/coursera-dl/coursera-dl/commit/7b0783433b6b198fca9e51405b18386f90790892.patch";
    })
  ];

  nativeBuildInputs = [ pandoc ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    mock
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    attrs
    beautifulsoup4
    configargparse
    distutils
    keyring
    pyasn1
    requests
    six
    urllib3
  ];

  disabledTests = [
    "test_get_credentials_with_keyring"
    "test_quiz_exam_to_markup_converter"
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "CLI for downloading Coursera.org videos and naming them";
    homepage = "https://github.com/coursera-dl/coursera-dl";
    changelog = "https://github.com/coursera-dl/coursera-dl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ alexfmpe ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "coursera-dl";
  };
})
