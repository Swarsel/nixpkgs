{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let
  games = {
    ctf = {
      version = "1.07";
      description = "'Capture The Flag' for Yamagi Quake II";
      id = "ctf";
      sha256 = "0i9bwhjvq6yhalrsbzjambh27fdzrzgswqz3jgfn9qw6k1kjvlin";
    };

    ground-zero = {
      version = "2.07";
      description = "'Ground Zero' for Yamagi Quake II";
      id = "rogue";
      sha256 = "1m2r4vgfdxpsi0lkf32liwf1433mdhhmjxiicjwzqjlkncjyfcb1";
    };

    the-reckoning = {
      version = "2.08";
      description = "'The Reckoning' for Yamagi Quake II";
      id = "xatrix";
      sha256 = "1wp9fg1q8nly2r9hh4394r1h4dxyni3lvdy7g419cz5s8hhn5msr";
    };
  };

  toDrv =
    title: data:
    stdenv.mkDerivation rec {
      inherit (data)
        id
        version
        description
        sha256
        ;

      inherit title;
      pname = "yquake2-${title}";

      src = fetchFromGitHub {
        inherit sha256;
        owner = "yquake2";
        repo = data.id;
        rev = "${lib.toUpper id}_${builtins.replaceStrings [ "." ] [ "_" ] version}";
      };

      env =
        # Uses `false` and `true` as enum constants, which are keywords in C23 (GCC 15 default)
        lib.optionalAttrs stdenv.cc.isGNU {
          NIX_CFLAGS_COMPILE = "-std=gnu17";
        };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/yquake2/${id}
        cp release/* $out/lib/yquake2/${id}
        runHook postInstall
      '';

      meta = {
        inherit (data) description;
        homepage = "https://www.yamagi.org/quake2/";
        license = lib.licenses.unfree;
        maintainers = with lib.maintainers; [ tadfisher ];
        platforms = lib.platforms.unix;
      };
    };

in
lib.mapAttrs toDrv games
