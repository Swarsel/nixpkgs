{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  mono,
}:

let
  version = "1.0.0";

  drv = stdenv.mkDerivation {
    inherit version;
    pname = "keepass-charactercopy";

    src = fetchurl {
      url = "https://github.com/SketchingDev/Character-Copy/releases/download/v${version}/CharacterCopy.plgx";
      sha256 = "f8a81a60cd1aacc04c92a242479a8e4210452add019c52ebfbb1810b58d8800a";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = {
      description = "Enables KeePass to copy individual characters by index";

      longDescription = ''
        Character Copy is a lightweight KeePass plugin that integrates into KeePass' entry menu and
        allows users to securely copy individual characters from
        an entry's protected string fields, such as the password field
      '';

      homepage = "https://github.com/SketchingDev/Character-Copy";
      # licensing info was found in source files https://github.com/SketchingDev/Character-Copy/search?q=license
      license = lib.licenses.gpl2;
      maintainers = with lib.maintainers; [ nazarewk ];

      platforms = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
    };
  };
in
# Mono is required to compile plugin at runtime, after loading.
buildEnv {
  inherit (drv) pname version;

  paths = [
    mono
    drv
  ];
}
