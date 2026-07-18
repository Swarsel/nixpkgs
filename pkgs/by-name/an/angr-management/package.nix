{
  lib,
  fetchFromGitHub,
  libxcb-cursor,
  python312,
}:

python312.pkgs.buildPythonApplication (finalAttrs: {
  pname = "angr-management";
  version = "9.2.154";

  src = fetchFromGitHub {
    owner = "angr";
    repo = "angr-management";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZaQRXCt6u5FGApiXTToJdIXBnBLv3emo13YG5ip0lJA=";
  };

  buildInputs = [ libxcb-cursor ];
  build-system = with python312.pkgs; [ setuptools ];

  dependencies =
    with python312.pkgs;
    (
      [
        # requirements from setup.cfg
        angr
        bidict
        binsync
        ipython
        pyqodeng-angr
        pyside6
        pyside6-qtads
        qtawesome
        qtpy
        requests
        rpyc
        thefuzz
        tomlkit
        # requirements from setup.cfg -- vendorized qtconsole package
        ipykernel
        jupyter-client
        jupyter-core
        packaging
        pygments
        pyzmq
        traitlets
      ]
      ++ angr.optional-dependencies.angrdb
      ++ requests.optional-dependencies.socks
      ++ thefuzz.optional-dependencies.speedup
    );

  pyproject = true;
  pythonImportsCheck = [ "angrmanagement" ];

  pythonRelaxDeps = [
    "angr"
    "binsync"
    "qtawesome"
  ];

  meta = {
    description = "Graphical binary analysis tool powered by the angr binary analysis platform";
    homepage = "https://github.com/angr/angr-management";
    changelog = "https://github.com/angr/angr-management/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      connornelson
      scoder12
    ];

    mainProgram = "angr-management";
  };
})
