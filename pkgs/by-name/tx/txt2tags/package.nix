{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "txt2tags";
  version = "3.9";

  src = fetchFromGitHub {
    owner = "txt2tags";
    repo = "txt2tags";
    tag = finalAttrs.version;
    hash = "sha256-PwPGJJg79ny13gEb1WmgIVHcXQppI/j5mhIyOZjR19k=";
  };

  postPatch = ''
    substituteInPlace test/lib.py \
      --replace-fail 'TXT2TAGS = os.path.join(TEST_DIR, "..", "txt2tags.py")' \
                     'TXT2TAGS = "${placeholder "out"}/bin/txt2tags"' \
      --replace-fail "[PYTHON] + TXT2TAGS" "TXT2TAGS"
  '';

  checkPhase = ''
    ${python3.interpreter} test/run.py
  '';

  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "txt2tags" ];

  meta = {
    description = "Convert between markup languages";
    homepage = "https://txt2tags.org/";
    changelog = "https://github.com/txt2tags/txt2tags/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      dotlambda
      kovirobi
    ];

    mainProgram = "txt2tags";
  };
})
