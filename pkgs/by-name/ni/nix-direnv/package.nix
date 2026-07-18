{
  lib,
  fetchFromGitHub,
  coreutils,
  nix,
  resholve,
  writeText,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "nix-direnv";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-direnv";
    rev = finalAttrs.version;
    hash = "sha256-3qT5mSqHi+0cskdoOGPVbuSzkoWtwOHBVXUOL84dAM8=";
  };

  installPhase = ''
    runHook preInstall
    install -m400 -D direnvrc $out/share/nix-direnv/direnvrc
    runHook postInstall
  '';

  solutions = {
    default = {
      fake = {
        builtin = [
          "PATH_add"
          "direnv_layout_dir"
          "has"
          "log_error"
          "log_status"
          "watch_file"
        ];

        external = [
          # We want to reference the ambient Nix when possible, and have custom logic
          # for the fallback
          "nix"
        ];

        function = [
          # not really a function - this is in an else branch for macOS/homebrew that
          # cannot be reached when built with nix
          "shasum"
        ];
      };

      inputs = [ coreutils ];
      interpreter = "none";

      keep = {
        "$NIX_DIRENV_FALLBACK_NIX" = true;
        # Nix fallback implementation
        "$_nix_direnv_nix" = true;
        "$ambient_nix" = true;
        "$cmd" = true;
        "$direnv" = true;
      };

      prologue =
        (writeText "prologue.sh" ''
          NIX_DIRENV_FALLBACK_NIX=''${NIX_DIRENV_FALLBACK_NIX:-${lib.getExe nix}}
        '').outPath;

      scripts = [ "share/nix-direnv/direnvrc" ];
    };
  };

  meta = {
    description = "Fast, persistent use_nix implementation for direnv";
    homepage = "https://github.com/nix-community/nix-direnv";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mic92
      bbenne10
    ];

    platforms = lib.platforms.unix;
  };
})
