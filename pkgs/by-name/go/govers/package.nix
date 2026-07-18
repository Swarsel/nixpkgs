{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "govers";
  version = "0-unstable-2016-06-23";

  src = fetchFromGitHub {
    owner = "rogpeppe";
    repo = "govers";
    rev = "77fd787551fc5e7ae30696e009e334d52d2d3a43";
    hash = "sha256-lpc8wFKAB+A8mBm9q3qNzTM8ktFS1MYdIvZVFP0eiIs=";
  };

  postPatch = ''
    go mod init github.com/rogpeppe/govers
  '';

  vendorHash = null;
  doCheck = false; # fails, silently
  dontRenameImports = true;

  meta = {
    description = "Tool for rewriting Go import paths";
    homepage = "https://github.com/rogpeppe/govers";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
    ];

    mainProgram = "govers";
  };
}
