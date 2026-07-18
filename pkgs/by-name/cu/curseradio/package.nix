{
  lib,
  fetchFromGitHub,
  mpv,
  python3Packages,
  replaceVars,
}:

python3Packages.buildPythonApplication {
  pname = "curseradio";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "chronitis";
    repo = "curseradio";
    rev = "1bd4bd0faeec675e0647bac9a100b526cba19f8d";
    sha256 = "11bf0jnj8h2fxhpdp498189r4s6b47vy4wripv0z4nx7lxajl88i";
  };

  patches = [
    (replaceVars ./mpv.patch {
      inherit mpv;
    })
  ];

  # No tests
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
    lxml
    pyxdg
  ];

  pyproject = true;

  meta = {
    description = "Command line radio player";
    homepage = "https://github.com/chronitis/curseradio";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.eyjhb ];
    mainProgram = "curseradio";
  };
}
