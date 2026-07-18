{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  enlighten,
  kivy,
  pycryptodome,
  zstandard,
  withGUI ? true,
}:

buildPythonPackage rec {
  pname = "nsz";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "nicoboss";
    repo = "nsz";
    tag = version;
    hash = "sha256-ch4HzQFa95o3HMsi7R0LpPWmhN/Z9EYfrmCdUZLwPSE=";
  };

  propagatedBuildInputs = [
    pycryptodome
    enlighten
    zstandard
  ]
  ++ lib.optional withGUI kivy;

  # do not check, as nsz requires producation keys
  # dumped from a Nintendo Switch.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Homebrew compatible NSP/XCI compressor/decompressor";
    homepage = "https://github.com/nicoboss/nsz";
    changelog = "https://github.com/nicoboss/nsz/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
    mainProgram = "nsz";
  };
}
