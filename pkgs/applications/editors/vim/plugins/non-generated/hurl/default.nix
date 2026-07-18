{
  hurl,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  inherit (hurl) version;
  pname = "hurl";
  # https://hurl.dev/
  src = "${hurl.src}/contrib/vim";
}
