{
  lib,
  fetchFromGitLab,
  apksigner,
  fetchPypi,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fdroidserver";
  version = "2.4.3";

  src = fetchFromGitLab {
    owner = "fdroid";
    repo = "fdroidserver";
    tag = finalAttrs.version;
    hash = "sha256-9gRMjqxYKB/OSu1vn3jtNy1hROCpm8yJptlhkTt2hZw=";
  };

  postPatch = ''
    substituteInPlace fdroidserver/common.py \
      --replace-fail "FDROID_PATH = os.path.realpath(os.path.join(os.path.dirname(__file__), '..'))" "FDROID_PATH = '$out/bin'"
  '';

  nativeBuildInputs = [ installShellFiles ];

  preConfigure = ''
    ${python3Packages.python.pythonOnBuildForHost.interpreter} setup.py compile_catalog
  '';

  # no tests
  doCheck = false;

  postInstall = ''
    patchShebangs gradlew-fdroid
    install -m 0755 gradlew-fdroid $out/bin
    installShellCompletion --cmd fdroid \
      --bash completion/bash-completion
  '';

  build-system = with python3Packages; [
    setuptools
    babel
  ];

  dependencies = with python3Packages; [
    androguard
    biplist
    clint
    defusedxml
    gitpython
    libcloud
    libvirt
    magic
    mwclient
    oscrypto
    paramiko
    pillow
    platformdirs
    pyasn1
    pyasn1-modules
    pycountry
    python-vagrant
    pyyaml
    qrcode
    requests
    (ruamel-yaml.overrideAttrs (old: {
      src = fetchPypi {
        hash = "sha256-i3zml6LyEnUqNcGsQURx3BbEJMlXO+SSa1b/P10jt68=";
        pname = "ruamel.yaml";
        version = "0.17.21";
      };
    }))
    sdkmanager
    yamllint
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ apksigner ]}"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fdroidserver" ];

  pythonRelaxDeps = [
    "androguard"
    "pyasn1"
    "pyasn1-modules"
  ];

  pythonRemoveDeps = [
    "puremagic" # Only used as a fallback when magic is not installed
  ];

  meta = {
    description = "Server and tools for F-Droid, the Free Software repository system for Android";
    homepage = "https://gitlab.com/fdroid/fdroidserver";
    changelog = "https://gitlab.com/fdroid/fdroidserver/-/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      linsui
      jugendhacker
    ];

    mainProgram = "fdroid";
  };
})
