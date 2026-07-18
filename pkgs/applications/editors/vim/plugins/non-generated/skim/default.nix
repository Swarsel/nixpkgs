{
  skim,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (skim) version;
  pname = "skim";
  src = skim.vim;
}
