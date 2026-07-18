{
  lib,
  stdenv,
  callPackage,
  fcft,
  fetchFromSourcehut,
  libxkbcommon,
  pixman,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zig_0_13,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wayprompt";
  version = "0.1.2";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = "wayprompt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+9Zgq5/Zbb1I3CMH1pivPkddThaGDXM+vVCzWppXq+0=";
  };

  nativeBuildInputs = [
    zig_0_13
    pkg-config
    wayland
    wayland-scanner
    scdoc
  ];

  buildInputs = [
    fcft
    libxkbcommon
    pixman
    wayland-protocols
  ];

  postFixup = ''
    substituteInPlace $out/bin/wayprompt-ssh-askpass \
      --replace-fail wayprompt $out/bin/wayprompt
  '';

  deps = callPackage ./build.zig.zon.nix { };

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  meta = {
    description = "Multi-purpose (password-)prompt tool for Wayland";
    homepage = "https://git.sr.ht/~leon_plickat/wayprompt";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ sg-qwt ];
    platforms = lib.platforms.linux;
    mainProgram = "pinentry-wayprompt";
  };
})
