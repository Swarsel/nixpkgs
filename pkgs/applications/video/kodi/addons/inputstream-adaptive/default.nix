{
  lib,
  stdenv,
  fetchFromGitHub,
  addonDir,
  buildKodiBinaryAddon,
  glib,
  gtest,
  nspr,
  nss,
  pugixml,
  rapidjson,
  rel,
}:
let
  bento4 = fetchFromGitHub {
    hash = "sha256-ycWQvXgr1DQ3Wng73S8i6y6XmcUD/iN8OKfO1czgsnY=";
    owner = "xbmc";
    repo = "Bento4";
    tag = "1.6.0-641-3-${rel}";
  };
in
buildKodiBinaryAddon rec {
  pname = "inputstream-adaptive";
  version = "21.5.18";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.adaptive";
    tag = "${version}-${rel}";
    hash = "sha256-JJaB0HlDLv5CFDE75sXW1e+vCc1BrqzZT6HyBa0LVso=";
  };

  extraBuildInputs = [
    pugixml
    rapidjson
  ];

  extraCMakeFlags = [
    "-DENABLE_INTERNAL_BENTO4=ON"
    "-DBENTO4_URL=${bento4}"
  ];

  extraInstallPhase =
    let
      n = namespace;
    in
    ''
      ${lib.optionalString stdenv.hostPlatform.isAarch64 "ln -s $out/lib/addons/${n}/libcdm_aarch64_loader.so $out/${addonDir}/${n}/libcdm_aarch64_loader.so"}
    '';

  extraNativeBuildInputs = [ gtest ];

  extraRuntimeDependencies = [
    glib
    nspr
    nss
    (lib.getLib stdenv.cc.cc)
  ];

  namespace = "inputstream.adaptive";

  meta = {
    description = "Kodi inputstream addon for several manifest types";
    homepage = "https://github.com/xbmc/inputstream.adaptive";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
