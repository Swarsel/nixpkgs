{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  pythonPackages = python3Packages;
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "nvpy";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "cpbotha";
    repo = "nvpy";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-guNdLu/bCk89o5M3gQU7J0W4h7eZdLHM0FG5IAPLE7c=";
  };

  # No tests
  doCheck = false;

  postInstall = ''
    install -dm755 "$out/share/licenses/nvpy/"
    install -m644 LICENSE.txt "$out/share/licenses/nvpy/LICENSE"

    install -dm755 "$out/share/doc/nvpy/"
    install -m644 README.rst "$out/share/doc/nvpy/README"
  '';

  build-system = with pythonPackages; [ setuptools ];

  dependencies = with pythonPackages; [
    markdown
    docutils
    simplenote
    tkinter
  ];

  pyproject = true;
  pythonImportsCheck = [ "nvpy" ];

  meta = {
    description = "Simplenote-syncing note-taking tool inspired by Notational Velocity";
    homepage = "https://github.com/cpbotha/nvpy";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "nvpy";
  };
})
