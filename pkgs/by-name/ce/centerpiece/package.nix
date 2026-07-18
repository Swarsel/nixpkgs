{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
  enableX11 ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "centerpiece";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "friedow";
    repo = "centerpiece";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tZNwMPL1ITWVvoywojsd5j0GIVQt6pOKFLwi7jwqLKg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    libGL
    libxkbcommon
    vulkan-loader
    wayland
  ]
  ++ lib.optionals enableX11 [
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  cargoHash = "sha256-qwKn9NN7+F/S8ojObjWBU2y2wG0TNeYbYHiwou8AhnI=";

  postFixup = lib.optional stdenv.hostPlatform.isLinux ''
    rpath=$(patchelf --print-rpath $out/bin/centerpiece)
    patchelf --set-rpath "$rpath:${
      lib.makeLibraryPath [
        libGL
        libxkbcommon
        vulkan-loader
        wayland
      ]
    }" $out/bin/centerpiece
  '';

  meta = {
    description = "Your trusty omnibox search";
    homepage = "https://github.com/friedow/centerpiece";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      a-kenji
      friedow
    ];

    platforms = lib.platforms.linux;
    mainProgram = "centerpiece";
  };
})
