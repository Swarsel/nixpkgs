{
  lib,
  fetchFromGitHub,
  ansible,
  ansible-pylibssh,
  buildPythonPackage,
  cryptography,
  docutils,
  installShellFiles,
  jinja2,
  junit-xml,
  lxml,
  ncclient,
  packaging,
  paramiko,
  pexpect,
  psutil,
  pycrypto,
  python,
  pythonOlder,
  pywinrm,
  pyyaml,
  requests,
  resolvelib,
  scp,
  setuptools,
  xmltodict,
  # Additional packages to add to dependencies
  extraPackages ? _: [ ],
  windowsSupport ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "ansible-core";
  version = "2.21.1";

  src = fetchFromGitHub {
    owner = "ansible";
    repo = "ansible";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VTU+jhD5W+07FIPVpovQoHjCb4vhLdPZNxCm/MVofV8=";
  };

  postPatch = ''
    patchShebangs --build packaging/cli-doc/build.py

    SETUPTOOLS_PATTERN='"setuptools[0-9 <>=.,]+"'
    WHEEL_PATTERN='"wheel[0-9 <>=.,]+"'
    echo "Patching pyproject.toml"
    # print replaced patterns to stdout
    sed -r -i -e 's/'"$SETUPTOOLS_PATTERN"'/"setuptools"/w /dev/stdout' \
      -e 's/'"$WHEEL_PATTERN"'/"wheel"/w /dev/stdout' pyproject.toml
  '';

  nativeBuildInputs = [
    installShellFiles
    docutils
  ];

  # internal import errors, missing dependencies
  doCheck = false;

  postInstall = ''
    export HOME="$(mktemp -d)"
    packaging/cli-doc/build.py man --output-dir=man
    installManPage man/*
  '';

  postFixup = ''
    patchPythonScript $out/${python.sitePackages}/ansible/cli/scripts/ansible_connection_cli_stub.py
  '';

  build-system = [ setuptools ];

  dependencies = [
    # depend on ansible instead of the other way around
    ansible
    # from requirements.txt
    cryptography
    jinja2
    packaging
    pyyaml
    resolvelib
    # optional dependencies
    junit-xml
    lxml
    ncclient
    paramiko
    ansible-pylibssh
    pexpect
    psutil
    pycrypto
    requests
    scp
    xmltodict
  ]
  ++ lib.optionals windowsSupport [ pywinrm ]
  ++ extraPackages python.pkgs;

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonRelaxDeps = [ "resolvelib" ];

  meta = {
    description = "Radically simple IT automation";
    homepage = "https://www.ansible.com";
    changelog = "https://github.com/ansible/ansible/blob/v${finalAttrs.version}/changelogs/CHANGELOG-v${lib.versions.majorMinor finalAttrs.version}.rst";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      HarisDotParis
      robsliwi
    ];
  };
})
