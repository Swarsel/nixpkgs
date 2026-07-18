{
  lib,
  fetchFromGitHub,
  cacert,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "matrix-commander";
  version = "8.0.5";

  src = fetchFromGitHub {
    owner = "8go";
    repo = "matrix-commander";
    rev = "v${version}";
    hash = "sha256-eNgnjErPi5q9yA/2iEg3+CoN2xbopmFOpbgU/7GhoAQ=";
  };

  postPatch = ''
    # Dependencies already bundled with Python
    sed -i \
      -e '/uuid/d' \
      -e '/argparse/d' \
      -e '/asyncio/d' \
      -e '/datetime/d' \
      setup.cfg requirements.txt
  '';

  propagatedBuildInputs = [
    cacert
  ]
  ++ (with python3Packages; [
    setuptools
    (matrix-nio.override { withOlm = true; })
    python-magic
    markdown
    pillow
    aiofiles
    notify2
    dbus-python
    pyxdg
    python-olm
    emoji
  ]);

  pyproject = true;

  meta = {
    description = "Simple but convenient CLI-based Matrix client app for sending and receiving";
    homepage = "https://github.com/8go/matrix-commander";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.seb314 ];
    platforms = lib.platforms.unix;
    mainProgram = "matrix-commander";
  };
}
