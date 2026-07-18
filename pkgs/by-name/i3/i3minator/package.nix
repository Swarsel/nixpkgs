{
  lib,
  fetchFromGitHub,
  glibcLocales,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "i3minator";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "carlesso";
    repo = "i3minator";
    rev = finalAttrs.version;
    sha256 = "07dic5d2m0zw0psginpl43xn0mpxw7wilj49d02knz69f7c416lm";
  };

  buildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";
  # No tests
  doCheck = false;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pyyaml
    python3Packages.i3-py
  ];

  pyproject = true;
  pythonImportsCheck = [ "i3minator" ];

  meta = {
    description = "i3 project manager similar to tmuxinator";

    longDescription = ''
      A simple "workspace manager" for i3. It allows to quickly
      manage workspaces defining windows and their layout. The
      project is inspired by tmuxinator and uses i3-py.
    '';

    homepage = "https://github.com/carlesso/i3minator";
    license = lib.licenses.wtfpl;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "i3minator";
  };

})
