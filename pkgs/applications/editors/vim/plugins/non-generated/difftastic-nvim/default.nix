{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  vimPlugins,
  vimUtils,
}:
let
  version = "0.0.9";
  src = fetchFromGitHub {
    owner = "clabby";
    repo = "difftastic.nvim";
    rev = "6041ef0244b3fecf3b7f07de9af8cfbf8dbc4945";
    hash = "sha256-23NGKhytF3OsLJgdrC51IH/sIGoqe/yBfmPsZKHOMSk=";
  };

  difftastic-nvim-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "difftastic-nvim-lib";
    cargoHash = "sha256-VSlFlLa4knQ7bH8yFHSKTTtt1cQ76dstlCdWBAtkf1I=";
    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";

    postInstall = ''
      ln -s $out/lib/libdifftastic_nvim${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/difftastic_nvim.so
    '';
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "difftastic-nvim";

  postPatch = ''
    substituteInPlace lua/difftastic-nvim/binary.lua \
      --replace-fail \
      'release_dir = plugin_root .. "/target/release"' \
      "release_dir = '${difftastic-nvim-lib}/lib'"
  '';

  dependencies = [
    vimPlugins.nui-nvim
  ];

  passthru = {
    # needed for the update script
    inherit difftastic-nvim-lib;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.difftastic-nvim.difftastic-nvim-lib";
    };

  };

  meta = {
    description = "Neovim plugin that displays difftastic's structural diffs in a side-by-side view with syntax highlighting";
    homepage = "https://github.com/clabby/difftastic.nvim/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      auscyber
    ];

    platforms = lib.platforms.unix;
  };
}
