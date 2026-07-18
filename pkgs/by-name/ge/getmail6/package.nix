{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "getmail6";
  version = "6.20.00";

  src = fetchFromGitHub {
    owner = "getmail6";
    repo = "getmail6";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f0IH0wI7Ue/HjvMIhBRGaMoO9BYDJoH/3fWRDsFD9+8=";
  };

  postPatch = ''
    # getmail spends a lot of effort to build an absolute path for
    # documentation installation; too bad it is counterproductive now
    sed -e '/datadir or prefix,/d' -i setup.py
    sed -e 's,/usr/bin/getmail,$(dirname $0)/getmail,' -i getmails
  '';

  # needs a Docker setup
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "getmailcore" ];

  meta = {
    description = "Program for retrieving mail";
    homepage = "https://getmail6.org";
    changelog = "https://github.com/getmail6/getmail6/blob/${finalAttrs.src.tag}/docs/CHANGELOG";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      abbe
      dotlambda
    ];
  };
})
