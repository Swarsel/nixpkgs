{
  taskwarrior3,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (taskwarrior3) version pname;
  src = "${taskwarrior3.src}/scripts/vim";
}
