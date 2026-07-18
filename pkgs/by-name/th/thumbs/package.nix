{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "thumbs";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "fcsonline";
    repo = "tmux-thumbs";
    rev = finalAttrs.version;
    sha256 = "sha256-XMz1ZOTz2q1Dt4QdxG83re9PIsgvxTTkytESkgKxhGM=";
  };

  patches = [ ./fix.patch ];
  cargoHash = "sha256-xvfjWS1QZWrlwytFyWVtjOyB3EPT9leodVLt72yyM4E=";

  meta = {
    description = "Lightning fast version of tmux-fingers written in Rust, copy/pasting tmux like vimium/vimperator";
    homepage = "https://github.com/fcsonline/tmux-thumbs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ghostbuster91 ];
  };
})
