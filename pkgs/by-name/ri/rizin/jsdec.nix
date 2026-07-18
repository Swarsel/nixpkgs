{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  openssl,
  pkg-config,
  rizin,
}:

let
  version = "0.8.0";

  libquickjs = fetchFromGitHub {
    hash = "sha256-o0Cpy+20EqNdNENaYlasJcKIGU7W4RYBcTMsQwFTUNc=";
    owner = "quickjs-ng";
    repo = "quickjs";
    tag = "v${version}";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jsdec";
  version = version;

  src = fetchFromGitHub {
    owner = "rizinorg";
    repo = "jsdec";
    rev = "v${version}";
    hash = "sha256-Xc8FMKSGdjrp288u49R6YC0xiynwHeoZe2P/UqnfsFU=";
  };

  postPatch = ''
    cp subprojects/packagefiles/libquickjs/* subprojects/libquickjs
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    openssl
    rizin
  ];

  postUnpack = ''
    cp -r --no-preserve=mode ${libquickjs} $sourceRoot/subprojects/libquickjs
  '';

  meta = {
    description = "Simple decompiler for Rizin";
    homepage = finalAttrs.src.meta.homepage;
    changelog = "${finalAttrs.src.meta.homepage}/releases/tag/${finalAttrs.src.rev}";

    license = with lib.licenses; [
      asl20
      bsd3
      mit
    ];

    maintainers = with lib.maintainers; [ chayleaf ];
  };
})
