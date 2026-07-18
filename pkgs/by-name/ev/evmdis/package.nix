{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "evmdis";
  version = "0-unstable-2022-05-09";

  src = fetchFromGitHub {
    owner = "Arachnid";
    repo = "evmdis";
    rev = "7fad4fbee443262839ce9f88111b417801163086";
    hash = "sha256-jfbjXoGT8RtwLlqX13kcKdiFlhrVwA7Ems6abGJVRbA=";
  };

  vendorHash = null;

  preBuild = ''
    go mod init github.com/Arachnid/evmdis
  '';

  ldflags = [ "-s" ];

  meta = {
    description = "Ethereum EVM disassembler";
    homepage = "https://github.com/Arachnid/evmdis";
    license = [ lib.licenses.asl20 ];
    maintainers = with lib.maintainers; [ asymmetric ];
    mainProgram = "evmdis";
  };
}
