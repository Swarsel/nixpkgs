{
  lib,
  fetchFromGitHub,
  glib,
  gtk4,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gnvim-unwrapped";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "vhakulinen";
    repo = "gnvim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VyyHlyMW/9zYECobQwngFARQYqcoXmopyCHUwHolXfo=";
  };

  # The default build script tries to get the version through Git, so we
  # replace it
  postPatch = ''
    # Install the binary ourselves, since the Makefile doesn't have the path
    # containing the target architecture
    sed -e "/target\/release/d" -i Makefile
  '';

  nativeBuildInputs = [
    pkg-config
    # for the `glib-compile-resources` command
    glib
  ];

  buildInputs = [
    glib
    gtk4
  ];

  cargoHash = "sha256-+i4fFiuNmc2+aFyOW2FxRZXINN1XF0nDJVsFYnIHI24=";
  # GTK fails to initialize
  doCheck = false;

  postInstall = ''
    make install PREFIX="${placeholder "out"}"
  '';

  meta = {
    description = "GUI for neovim, without any web bloat";
    homepage = "https://github.com/vhakulinen/gnvim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
    mainProgram = "gnvim";
  };
})
