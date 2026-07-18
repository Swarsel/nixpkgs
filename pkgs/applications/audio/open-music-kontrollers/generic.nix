{
  lib,
  stdenv,
  fetchurl,
  description,
  glew,
  libx11,
  libxext,
  lv2,
  lv2lint,
  meson,
  ninja,
  pkg-config,
  pname,
  sha256,
  sord,
  version,
  additionalBuildInputs ? [ ],
  postPatch ? "",
  url ? "https://git.open-music-kontrollers.ch/lv2/${pname}.lv2/snapshot/${pname}.lv2-${version}.tar.xz",
  ...
}:

stdenv.mkDerivation {
  inherit pname;
  inherit version;
  inherit postPatch;

  src = fetchurl {
    url = url;
    sha256 = sha256;
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    lv2
    sord
    libx11
    libxext
    glew
    lv2lint
  ]
  ++ additionalBuildInputs;

  meta = {
    description = description;
    homepage = "https://open-music-kontrollers.ch/lv2/${pname}:";
    license = lib.licenses.artistic2;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
