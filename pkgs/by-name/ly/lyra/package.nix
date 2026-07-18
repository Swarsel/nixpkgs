{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lyra";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "bfgroup";
    repo = "lyra";
    rev = finalAttrs.version;
    sha256 = "sha256-X8wJwSfOo7v2SKYrKJ4RhpEmOdEkS8lPHIqCxP46VF4=";
  };

  postPatch = "sed -i s#/usr#$out#g meson.build";

  nativeBuildInputs = [
    meson
    ninja
  ];

  postInstall = ''
    mkdir -p $out/include
    cp -R $src/include/* $out/include
  '';

  meta = {
    description = "Simple to use, composable, command line parser for C++ 11 and beyond";
    homepage = "https://github.com/bfgroup/Lyra";
    license = lib.licenses.boost;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
