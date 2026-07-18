{ mirth, vimUtils }:

vimUtils.buildVimPlugin {
  inherit (mirth) version;
  pname = "mirth";
  src = mirth.vim;

  meta = {
    inherit (mirth.meta)
      homepage
      license
      platforms
      ;

    description = "Syntax highlighting & filetype detection for the Mirth programming language";
  };
}
