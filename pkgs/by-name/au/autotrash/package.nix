{
  lib,
  fetchFromGitHub,
  installShellFiles,
  pandoc,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "autotrash";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "bneijt";
    repo = "autotrash";
    tag = finalAttrs.version;
    hash = "sha256-qMU3jjBL5+fd9vKX5BIqES5AM8D/54aBOmdHFiBtfEo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    installShellFiles
    pandoc
  ];

  postBuild = "make -C doc autotrash.1";
  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  postInstall = "installManPage doc/autotrash.1";
  build-system = [ python3Packages.poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "autotrash" ];

  meta = {
    description = "Tool to automatically purge old trashed files";
    homepage = "https://bneijt.nl/pr/autotrash";
    changelog = "https://github.com/bneijt/autotrash/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      sigmanificient
      mithicspirit
    ];

    mainProgram = "autotrash";
  };
})
