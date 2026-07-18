{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  ruby,
}:
let
  version = "1.1";
  gems = bundlerEnv {
    inherit ruby;
    gemdir = ./.;
    name = "tree-from-tags-${version}-gems";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "tree-from-tags";

  src = fetchFromGitHub {
    owner = "dbrock";
    repo = "bongo";
    rev = version;
    hash = "sha256-G+6rRJLNBECxGc8WuaesXhrYqvEDy2Chpw4lWxO8X9s=";
  };

  buildInputs = [
    gems
    ruby
  ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp tree-from-tags.rb $out/share/
    bin=$out/bin/tree-from-tags
    # we are using bundle exec to start in the bundled environment
    cat > $bin <<EOF
    #!/bin/sh -e
    exec ${gems}/bin/bundle exec ${ruby}/bin/ruby "$out"/share/tree-from-tags.rb "\$@"
    EOF
    chmod +x $bin
  '';

  meta = {
    description = "Create file hierarchies from media tags";
    homepage = "https://www.emacswiki.org/emacs/Bongo";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      livnev
      dbrock
    ];

    platforms = ruby.meta.platforms;
    mainProgram = "tree-from-tags";
  };
}
