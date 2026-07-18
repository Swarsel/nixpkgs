{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  gtest,
  icu,
  libmicrohttpd,
  libzim,
  meson,
  mustache-hpp,
  ninja,
  nix-update-script,
  pkg-config,
  pugixml,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libkiwix";
  version = "14.2.1";

  src = fetchFromGitHub {
    owner = "kiwix";
    repo = "libkiwix";
    rev = finalAttrs.version;
    hash = "sha256-wkUcQSBXrKw4Jx/ij12Nj45Jem6i7kun/gu1pJDOQeA=";
  };

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    icu
    zlib
    mustache-hpp
  ];

  propagatedBuildInputs = [
    curl
    libmicrohttpd
    libzim
    pugixml
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
  ];

  # Required for server tests on Darwin
  __darwinAllowLocalNetworking = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Common code base for all Kiwix ports";
    homepage = "https://kiwix.org";
    changelog = "https://github.com/kiwix/libkiwix/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
