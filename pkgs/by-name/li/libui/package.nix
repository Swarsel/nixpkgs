{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libui";
  version = "4.1a-unstable-2021-01-02";

  src = fetchFromGitHub {
    owner = "andlabs";
    repo = "libui";
    rev = "fea45b2d5b75839be0af9acc842a147c5cba9295";
    hash = "sha256-BGbL15hBHY4aZE2ANAEd677vzZMQzMCICBafRtoQIvA=";
  };

  patches = [
    ./darwin_versions.patch
    ./pkg-config.patch
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --subst-var-by version "${finalAttrs.version}"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace darwin/text.m unix/text.c \
      --replace-fail "strcasecmp" "g_strcasecmp"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = lib.optional stdenv.hostPlatform.isLinux gtk3;

  meta = {
    description = "Simple and portable (but not inflexible) GUI library in C that uses the native GUI technologies of each platform it supports";
    homepage = "https://github.com/andlabs/libui";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
