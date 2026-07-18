{
  lib,
  stdenv,
  gnvim-unwrapped,
  makeWrapper,
  neovim,
}:

stdenv.mkDerivation {
  inherit (gnvim-unwrapped) meta;
  pname = "gnvim";
  version = gnvim-unwrapped.version;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildCommand = ''
    makeWrapper '${gnvim-unwrapped}/bin/gnvim' "$out/bin/gnvim" \
      --prefix PATH : "${neovim}/bin" \
      --set GNVIM_RUNTIME_PATH "${gnvim-unwrapped}/share/gnvim/runtime"
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mkdir -p "$out/share"
    ln -s '${gnvim-unwrapped}/share/icons' "$out/share/icons"

    # copy and fix .desktop file
    cp -r '${gnvim-unwrapped}/share/applications' "$out/share/applications"
    # Sed needs a writable directory to do inplace modifications
    chmod u+rw "$out/share/applications"
    sed -e "s|Exec=.\\+gnvim\\>|Exec=gnvim|" -i $out/share/applications/*.desktop
  '';

  preferLocalBuild = true;
  passthru.unwrapped = gnvim-unwrapped;
}
