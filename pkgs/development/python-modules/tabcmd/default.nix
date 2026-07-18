{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  doit,
  ftfy,
  mock,
  pytest-order,
  pytestCheckHook,
  python,
  requests,
  setuptools,
  setuptools-scm,
  tableauserverclient,
  types-appdirs,
  types-mock,
  types-requests,
  types-setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "tabcmd";
  version = "2.0.20";

  src = fetchFromGitHub {
    owner = "tableau";
    repo = "tabcmd";
    tag = "v${version}";
    hash = "sha256-BviaCIav8rz37ac126KS4p54gbxzd6vs1p5kTy42bv4=";
  };

  nativeCheckInputs = [
    mock
    pytest-order
    pytestCheckHook
  ];

  # Create a "tabcmd" executable
  postInstall = ''
    # Create a directory for our wrapped binary.
    mkdir -p $out/bin

    cp -r build/lib/tabcmd/__main__.py $out/bin/

    # Create a 'tabcmd' script with python3 shebang
    echo "#!${python.interpreter}" > $out/bin/tabcmd

    # Append __main__.py contents
    cat $out/bin/__main__.py >> $out/bin/tabcmd

    # Make it executable.
    chmod +x $out/bin/tabcmd
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    appdirs
    doit
    ftfy
    requests
    setuptools-scm
    tableauserverclient
    types-appdirs
    types-mock
    types-requests
    types-setuptools
    urllib3
  ];

  prePatch = ''
    # Remove an unneeded dependency that can't be resolved
    # https://github.com/tableau/tabcmd/pull/282
    sed -i "/'argparse',/d" pyproject.toml
    # Uses setuptools-scm instead
    sed -i "/'pyinstaller_versionfile',/d" pyproject.toml
  '';

  pyproject = true;
  pythonImportsCheck = [ "tabcmd" ];

  pythonRelaxDeps = [
    "tableauserverclient"
    "urllib3"
  ];

  pythonRemoveDeps = [
    "pyinstaller_versionfile"
  ];

  meta = {
    description = "Command line client for working with Tableau Server";
    homepage = "https://github.com/tableau/tabcmd";
    changelog = "https://github.com/tableau/tabcmd/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tabcmd";
  };
}
