{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  capnproto,
  cmake,
  glog,
  gtest,
  leveldb,
  librime-lua,
  librime-octagram,
  marisa,
  opencc,
  pkg-config,
  yaml-cpp,
  plugins ? [
    librime-lua
    librime-octagram
  ],
}:

let
  copySinglePlugin = plug: "cp -r ${plug} plugins/${plug.name}";
  copyPlugins = ''
    mkdir -p plugins
    ${lib.concatMapStringsSep "\n" copySinglePlugin plugins}
    chmod +w -R plugins/*
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "librime";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "librime";
    rev = finalAttrs.version;
    sha256 = "sha256-HhmLA5W4+8BVGTozKCWCNhrXOIlRlLN/FiOBHKvUGcM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    glog
    leveldb
    marisa
    opencc
    yaml-cpp
    gtest
    capnproto
  ]
  ++ plugins; # for propagated build inputs

  preConfigure = copyPlugins;

  meta = {
    description = "Rime Input Method Engine, the core library";
    homepage = "https://rime.im/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ vonfry ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
