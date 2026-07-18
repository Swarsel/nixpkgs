{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  duktape,
  exiv2,
  ffmpeg,
  ffmpegthumbnailer,
  file,
  fmt,
  icu77,
  inotify-tools,
  jsoncpp,
  libebml,
  libexif,
  # required
  libiconv,
  libmatroska,
  libmysqlclient,
  libupnp,
  libuuid,
  nixosTests,
  pkg-config,
  pugixml,
  spdlog,
  sqlite,
  taglib,
  wavpack,
  zlib,
  enableAvcodec ? false,
  enableCurl ? true,
  enableDuktape ? true,
  enableExiv2 ? false,
  enableFFmpegThumbnailer ? false,
  enableInotifyTools ? true,
  enableLibexif ? true,
  enableLibmagic ? true,
  enableLibmatroska ? true,
  # options
  enableMysql ? false,
  enableTaglib ? true,
  enableWavPack ? false,
}:

let
  libupnp' = libupnp.overrideAttrs (super: {
    cmakeFlags = super.cmakeFlags or [ ] ++ [
      "-Dblocking_tcp_connections=OFF"
      "-Dreuseaddr=ON"
    ];
  });

  options = [
    {
      enable = enableAvcodec;
      name = "AVCODEC";
      packages = [ ffmpeg ];
    }
    {
      enable = enableCurl;
      name = "CURL";
      packages = [ curl ];
    }
    {
      enable = enableLibexif;
      name = "EXIF";
      packages = [ libexif ];
    }
    {
      enable = enableExiv2;
      name = "EXIV2";
      packages = [ exiv2 ];
    }
    {
      enable = enableFFmpegThumbnailer;
      name = "FFMPEGTHUMBNAILER";
      packages = [ ffmpegthumbnailer ];
    }
    {
      enable = enableInotifyTools;
      name = "INOTIFY";
      packages = [ inotify-tools ];
    }
    {
      enable = enableDuktape;
      name = "JS";
      packages = [ duktape ];
    }
    {
      enable = enableLibmagic;
      name = "MAGIC";
      packages = [ file ];
    }
    {
      enable = enableLibmatroska;
      name = "MATROSKA";

      packages = [
        libmatroska
        libebml
      ];
    }
    {
      enable = enableMysql;
      name = "MYSQL";
      packages = [ libmysqlclient ];
    }
    {
      enable = enableTaglib;
      name = "TAGLIB";
      packages = [ taglib ];
    }
    {
      enable = enableWavPack;
      name = "WAVPACK";
      packages = [ wavpack ];
    }
  ];

  inherit (lib) flatten;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "gerbera";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "gerbera";
    repo = "gerbera";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-dszd4WSTjOWwLNha0yq1gtC5kxCrJMhnnhKYaor8JyU=";
  };

  postPatch =
    let
      mysqlPatch = lib.optionalString enableMysql ''
        substituteInPlace cmake/FindMySQL.cmake \
          --replace /usr/include/mysql ${lib.getDev libmysqlclient}/include/mariadb \
          --replace /usr/lib/mysql     ${lib.getLib libmysqlclient}/lib/mariadb
      '';
    in
    ''
      ${mysqlPatch}
      substituteInPlace CMakeLists.txt --replace-fail /usr/share/bash-completion/completions $out/share/bash-completion/completions
    '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libiconv
    libupnp'
    libuuid
    pugixml
    spdlog
    sqlite
    zlib
    fmt
    jsoncpp
    icu77
  ]
  ++ flatten (builtins.catAttrs "packages" (builtins.filter (e: e.enable) options));

  cmakeFlags = [
    # systemd service will be generated alongside the service
    "-DWITH_SYSTEMD=OFF"
  ]
  ++ map (e: "-DWITH_${e.name}=${if e.enable then "ON" else "OFF"}") options;

  passthru.tests = { inherit (nixosTests) mediatomb; };

  meta = {
    description = "UPnP Media Server for 2024";

    longDescription = ''
      Gerbera is a Mediatomb fork.
      It allows to stream your digital media through your home network and consume it on all kinds
      of UPnP supporting devices.
    '';

    homepage = "https://docs.gerbera.io/";
    changelog = "https://github.com/gerbera/gerbera/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ardumont ];
    platforms = lib.platforms.linux;
    mainProgram = "gerbera";
  };
})
