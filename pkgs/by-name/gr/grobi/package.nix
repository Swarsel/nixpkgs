{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "grobi";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "fd0";
    repo = "grobi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-evgDY+OjfQ0ngf4j/D4yOeITHQXmBmw8KiJhLKjdVAw=";
  };

  patches = [
    # fix failing test on go 1.15
    (fetchpatch {
      hash = "sha256-YfjRV7kQxxGw3nQgB12tZOAJKBW21d9xx6BSou0bHkk=";
      url = "https://github.com/fd0/grobi/commit/176988ab087ff92d1408fbc454c77263457f3d7e.patch";
    })
  ];

  vendorHash = "sha256-cvP8M9pW58WwHvhXTMYqivNVGzHjDYlOd8/PvnLpfMU=";

  meta = {
    description = "Automatically configure monitors/outputs for Xorg via RANDR";
    homepage = "https://github.com/fd0/grobi";
    license = with lib.licenses; [ bsd2 ];
    platforms = lib.platforms.linux;
    mainProgram = "grobi";
  };
})
