{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rexi";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "royreznik";
    repo = "rexi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tag2/QTM6tDCU3qr4e1GqRYAZgpvEgtA+FtR4P7WdiU=";
  };

  # AttributeError: 'Static' object has no attribute 'renderable'.
  # In textual==0.6.0, the `renderable` property was renamed to `content`
  # https://github.com/Textualize/textual/pull/6041
  postPatch = ''
    substituteInPlace tests/test_ui.py \
      --replace-fail ".renderable" ".content"
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    colorama
    typer
    textual
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "textual"
    "typer"
  ];

  meta = {
    description = "User-friendly terminal UI to interactively work with regular expressions";
    homepage = "https://github.com/royreznik/rexi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gauravghodinde ];
    mainProgram = "rexi";
  };
})
