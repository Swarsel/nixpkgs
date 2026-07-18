{
  lib,
  fetchPypi,
  ffmpeg,
  installShellFiles,
  python3,
  replaceVars,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "you-get";
  version = "0.4.1700";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XNIUkgEqRGrBtSxvfkSUSqxltZ6ZdkWoTc9kz4BD6Zw=";
  };

  patches = [
    (replaceVars ./ffmpeg-path.patch {
      version = lib.getVersion ffmpeg;
      ffmpeg = "${lib.getBin ffmpeg}/bin/ffmpeg";
      ffprobe = "${lib.getBin ffmpeg}/bin/ffmpeg";
    })
  ];

  nativeBuildInputs = [ installShellFiles ];
  # Tests aren't packaged, but they all hit the real network so
  # probably aren't suitable for a build environment anyway.
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd you-get \
      --zsh contrib/completion/_you-get \
      --fish contrib/completion/you-get.fish \
      --bash contrib/completion/you-get-completion.bash
  '';

  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "you_get"
  ];

  meta = {
    description = "Tiny command line utility to download media contents from the web";
    homepage = "https://you-get.org";
    changelog = "https://github.com/soimort/you-get/raw/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryneeverett ];
    mainProgram = "you-get";
  };
})
