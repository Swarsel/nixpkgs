{
  parinfer-rust,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (parinfer-rust) pname version meta;
  src = parinfer-rust;
}
