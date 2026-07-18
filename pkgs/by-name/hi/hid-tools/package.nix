{
  lib,
  fetchFromGitLab,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "hid-tools";
  version = "0.7";

  src = fetchFromGitLab {
    owner = "libevdev";
    repo = "hid-tools";
    rev = version;
    hash = "sha256-h880jJcZDc9pIPf+nr30wu2i9y3saAKFZpooJ4MF67E=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pypandoc_binary" "pypandoc"
  '';

  nativeBuildInputs = with python3.pkgs; [
    hatchling
    pypandoc
  ];

  propagatedBuildInputs = with python3.pkgs; [
    libevdev
    parse
    pyyaml
    click
    pyudev
    typing-extensions
  ];

  # Tests require /dev/uhid
  # https://gitlab.freedesktop.org/libevdev/hid-tools/-/issues/18#note_166353
  doCheck = false;

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  pyproject = true;

  meta = {
    description = "Python scripts to manipulate HID data";
    homepage = "https://gitlab.freedesktop.org/libevdev/hid-tools";
    license = lib.licenses.mit;
    teams = [ lib.teams.freedesktop ];
  };
}
