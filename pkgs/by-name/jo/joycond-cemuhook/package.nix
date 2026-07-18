{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "joycond-cemuhook";
  version = "0-unstable-2024-12-27";

  src = fetchFromGitHub {
    owner = "joaorb64";
    repo = "joycond-cemuhook";
    rev = "fc2f29e22640b6615a32941cbdc03d41e3ee6f26";
    hash = "sha256-ud9X+GfVzoPQM4bSDzczgrn8rJRmXy7tT6mBY3BNnFA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'setuptools-git-versioning<2' "setuptools-git-versioning"
  '';

  build-system = with python3Packages; [
    setuptools
    wheel
    setuptools-git-versioning
  ];

  dependencies = with python3Packages; [
    evdev
    pyudev
    dbus-python
    termcolor
    pygobject-stubs
    # Not explicitly stated, but required
    pygobject3
  ];

  pyproject = true;

  meta = {
    description = "Support for cemuhook's UDP protocol for joycond devices";
    homepage = "https://github.com/joaorb64/joycond-cemuhook";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.noodlez1232 ];
    platforms = lib.platforms.linux;
    mainProgram = "joycond-cemuhook";
  };
}
