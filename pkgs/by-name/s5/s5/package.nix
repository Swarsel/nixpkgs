{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "s5";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mvisonneau";
    repo = "s5";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aNNf7ntGg2A84jD6UeoF4gFv8S/FonbIhV3ZOd/P4bw=";
  };

  vendorHash = "sha256-NmnYv0yAHmlOY9UK7GQtb5e9DwbyEbqQ2O6cpqkwtww=";
  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X github.com/mvisonneau/s5/internal/app.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/s5" ];

  meta = {
    description = "Cipher/decipher text within a file";
    homepage = "https://github.com/mvisonneau/s5";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mvisonneau ];
    platforms = lib.platforms.unix ++ lib.platforms.darwin;
    mainProgram = "s5";
  };
})
