{
  lib,
  fetchFromGitHub,
  php82,
  versionCheckHook,
}:

php82.buildComposerProject2 (finalAttrs: {
  pname = "robo";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "consolidation";
    repo = "robo";
    tag = finalAttrs.version;
    hash = "sha256-OYuP56KlS9onuYcy9xL0XrH9hqf/njwVUju1pDyRgKM=";
  };

  vendorHash = "sha256-rOFY9TymSw8MatAR/yCpKaj0LupuhaIkk7QAnaKQUZ4=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Modern task runner for PHP";
    homepage = "https://github.com/consolidation/robo";
    changelog = "https://github.com/consolidation/robo/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "robo";
  };
})
