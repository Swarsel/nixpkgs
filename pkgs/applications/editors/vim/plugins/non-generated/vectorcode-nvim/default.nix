{
  lib,
  vectorcode,
  vimPlugins,
  vimUtils,
}:
let
  inherit (vectorcode) src version;
in
vimUtils.buildVimPlugin {
  inherit src version;
  pname = "vectorcode.nvim";

  postPatch = ''
    cp -r ../lua .
  '';

  buildInputs = [ vectorcode ];

  checkInputs = [
    vimPlugins.codecompanion-nvim
  ];

  dependencies = [
    vimPlugins.plenary-nvim
  ];

  # nixpkgs-update: no auto update
  # This is built from the same source as vectorcode and will rebuild automatically
  sourceRoot = "${src.name}/plugin";

  meta = {
    inherit (vectorcode.meta) changelog license;
    description = "Index and navigate your code repository using vectorcode";
    homepage = "https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/README.md";
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
