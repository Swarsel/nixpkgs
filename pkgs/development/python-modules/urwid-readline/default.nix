{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  urwid,
}:

buildPythonPackage rec {
  pname = "urwid-readline";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "rr-";
    repo = "urwid_readline";
    tag = version;
    hash = "sha256-HiMMLzVE/Qw/PR7LXACyfzblxrGYrbMoi3/e/QzqF34=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'version="0.15"' 'version="${version}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ urwid ];
  pyproject = true;
  pythonImportsCheck = [ "urwid_readline" ];

  meta = {
    description = "Textbox edit widget for urwid that supports readline shortcuts";
    homepage = "https://github.com/rr-/urwid_readline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
