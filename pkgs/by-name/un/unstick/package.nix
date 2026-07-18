{
  lib,
  stdenv,
  fetchFromGitHub,
  libseccomp,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unstick";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kwohlfahrt";
    repo = "unstick";
    rev = "effee9aa242ca12dc94cc6e96bc073f4cc9e8657";
    sha256 = "08la3jmmzlf4pm48bf9zx4cqj9gbqalpqy0s57bh5vfsdk74nnhv";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ libseccomp ];
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Silently eats chmod commands forbidden by Nix";
    homepage = "https://github.com/kwohlfahrt/unstick";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ kwohlfahrt ];
    platforms = lib.platforms.linux;
    mainProgram = "unstick";
  };
})
