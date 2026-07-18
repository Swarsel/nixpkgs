{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildPythonPackage,
  colorama,
  distro,
  packaging,
  psutil,
  python-dateutil,
  pyyaml,
  requests,
  requests-cache,
  requests-toolbelt,
  resolvelib,
  setuptools,
  stevedore,
  tqdm,
}:

buildPythonPackage rec {
  pname = "e3-core";
  version = "22.10.0";

  src = fetchFromGitHub {
    owner = "AdaCore";
    repo = "e3-core";
    tag = "v${version}";
    hash = "sha256-LHWtgIvbS1PaF85aOpdhR0rWQGRUtbY0Qg1SZxQOsSc=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  # e3-core is tested with tox; it's hard to test without internet.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    colorama
    packaging
    python-dateutil
    pyyaml
    requests
    requests-cache
    requests-toolbelt
    resolvelib
    stevedore
    tqdm
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # See https://github.com/AdaCore/e3-core/blob/v22.6.0/pyproject.toml#L37-L42
    # These are required only on Linux. Darwin has its own set of requirements
    psutil
    distro
  ];

  pyproject = true;
  pythonImportsCheck = [ "e3" ];

  meta = {
    description = "Core framework for developing portable automated build systems";
    homepage = "https://github.com/AdaCore/e3-core/";
    changelog = "https://github.com/AdaCore/e3-core/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ atalii ];
    # See the comment regarding distro and psutil. Other platforms are supported
    # upstream, but not by this package.
    platforms = lib.platforms.linux;
    mainProgram = "e3";
  };
}
