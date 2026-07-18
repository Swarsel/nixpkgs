{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nile";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "imLinguin";
    repo = "nile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tzf3sqD7P32AXzZu/WDauOSsEe/xhCh6x4KGQ1YnJqw=";
  };

  postPatch = ''
    echo "$pyprojectAppendix" >> pyproject.toml
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    setuptools
    requests
    protobuf
    pycryptodome
    zstandard
    json5
    platformdirs
  ];

  pyproject = true;

  pyprojectAppendix = ''
    [tool.setuptools.packages.find]
    include = ["nile*"]
  '';

  pythonImportsCheck = [ "nile" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Unofficial Amazon Games client";
    homepage = "https://github.com/imLinguin/nile";
    changelog = "https://github.com/imLinguin/nile/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "nile";
  };
})
