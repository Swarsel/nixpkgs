{
  lib,
  meson,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (meson) pname version src;
  preInstall = "cd data/syntax-highlighting/vim";

  meta = {
    inherit (meson.meta)
      homepage
      license
      platforms
      ;

    description = "Vim plugin for meson providing syntax highlighting";
    maintainers = with lib.maintainers; [ vcunat ];
  };
}
