{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "procfd";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "deshaw";
    repo = "procfd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z18DUXT26ZRFbD25pCKqPlEnxboQKhyhKysXeOsebcE=";
  };

  cargoHash = "sha256-QsdHNZnh86qQTE6ZtycrzqU+L72EBmRlRNqJ2CRU4MI=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Linux lsof replacement to list open file descriptors for processes";
    homepage = "https://github.com/deshaw/procfd";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      de11n
      despsyched
    ];

    platforms = lib.platforms.linux;
    mainProgram = "procfd";
  };
})
