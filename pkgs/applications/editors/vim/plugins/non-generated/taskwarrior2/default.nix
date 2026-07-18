{
  taskwarrior2,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (taskwarrior2) version pname;
  src = "${taskwarrior2.src}/scripts/vim";
}
