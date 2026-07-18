{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:

buildGoModule (finalAttrs: {
  pname = "vim-startuptime";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "vim-startuptime";
    rev = "v${finalAttrs.version}";
    hash = "sha256-d6AXTWTUawkBCXCvMs3C937qoRUZmy0qCFdSLcWh0BE=";
  };

  vendorHash = null;

  nativeCheckInputs = with pkgs; [
    vim
    neovim
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Small Go program for better `vim --startuptime` alternative";
    homepage = "https://github.com/rhysd/vim-startuptime";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "vim-startuptime";
  };
})
