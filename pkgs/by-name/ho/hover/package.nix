{
  lib,
  fetchFromGitHub,
  addDriverRunpath,
  binutils,
  buildFHSEnv,
  buildGoModule,
  dejavu_fonts,
  flutter,
  gcc,
  go,
  libglvnd,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxxf86vm,
  makeWrapper,
  pkg-config,
  roboto,
  xorgproto,
}:

let
  pname = "hover";
  version = "0.47.2";

  libs = [
    libx11.dev
    libxcursor.dev
    libxext.dev
    libxi.dev
    libxinerama.dev
    libxrandr.dev
    libxrender.dev
    libxfixes.dev
    libxxf86vm
    libglvnd.dev
    xorgproto
  ];
  hover = buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "go-flutter-desktop";
      repo = "hover";
      tag = "v${version}";
      sha256 = "sha256-xS4qfsGZAt560dxHpwEnAWdJCd5vuTdX+7fpUGrSqhw=";
    };

    nativeBuildInputs = [
      addDriverRunpath
      makeWrapper
    ];

    buildInputs = libs;
    vendorHash = "sha256-LDVF1vt1kTm7G/zqWHcjtGK+BsydgmJUET61+sILiE0=";

    postInstall = ''
      wrapProgram "$out/bin/hover" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs}
    '';

    postFixup = ''
      addDriverRunpath $out/bin/hover
    '';

    checkRun = false;
    subPackages = [ "." ];

    meta = {
      description = "Build tool to run Flutter applications on desktop";
      homepage = "https://github.com/go-flutter-desktop/hover";
      license = [ lib.licenses.bsd3 ];
      maintainers = [ lib.maintainers.ericdallo ];
      platforms = lib.platforms.linux;
    };
  };

in
buildFHSEnv {
  inherit pname version;
  runScript = "hover";

  targetPkgs =
    pkgs:
    [
      binutils
      dejavu_fonts
      flutter
      gcc
      go
      hover
      pkg-config
      roboto
    ]
    ++ libs;
}
