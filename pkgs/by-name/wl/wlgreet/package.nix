{
  lib,
  autoPatchelfHook,
  fetchFromSourcehut,
  gcc-unwrapped,
  libxkbcommon,
  nix-update-script,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wlgreet";
  version = "0.5.0";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "wlgreet";
    rev = finalAttrs.version;
    hash = "sha256-TQTHFBOTxtSuzrAG4cjZ9oirl80xc0rPdYeLJ0t39DQ=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc-unwrapped ];
  cargoHash = "sha256-ITo9qvcT5aOybWLV7kn9BZbux6uxx1RwRGWCGQYdZ2I=";

  runtimeDependencies = map lib.getLib [
    gcc-unwrapped
    wayland
    libxkbcommon
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Raw wayland greeter for greetd, to be run under sway or similar";
    homepage = "https://git.sr.ht/~kennylevinsen/wlgreet";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "wlgreet";
  };
})
