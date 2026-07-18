{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  fetchpatch,
  fontconfig,
  libgcc,
  libxkbcommon,
  pkg-config,
  rustPlatform,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yofi";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "l4l";
    repo = "yofi";
    tag = finalAttrs.version;
    hash = "sha256-cepAZyA4RBgqeF20g6YOlZTM0aRqErw17yuQ3U24UEg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = [
    libgcc
    libxkbcommon
  ];

  cargoHash = "sha256-UCJlBVQb4aLObi5hqXnh/FAD7l2VSocAlqmYMlxLUJc=";

  checkFlags = [
    # Fail to run in sandbox environment.
    "--skip=screen::context::test"
  ];

  appendRunpaths = [
    (lib.makeLibraryPath [
      fontconfig
      wayland
    ])
  ];

  cargoPatches = [
    (fetchpatch {
      hash = "sha256-o/kwQRIG6MASGYnepb96pL1qfI+/CNTqc5maDPjSZXk=";
      name = "bump-time-1.80.0.patch";
      url = "https://github.com/l4l/yofi/commit/438e180bf5132d29a6846e830d7227cb996ade3e.patch";
    })
  ];

  meta = {
    description = "Minimalist app launcher in Rust";
    homepage = "https://github.com/l4l/yofi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rayslash ];
    platforms = lib.platforms.linux;
    mainProgram = "yofi";
  };
})
