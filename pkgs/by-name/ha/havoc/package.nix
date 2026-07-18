{
  lib,
  stdenv,
  fetchFromGitHub,
  libxkbcommon,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "havoc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "ii8";
    repo = "havoc";
    rev = finalAttrs.version;
    hash = "sha256-Hn0HrAgxrkfN+iXAt+C4rOd3/Z+ZKFVk3GGNgVtro7A=";
  };

  nativeBuildInputs = [
    wayland-protocols
    wayland-scanner
  ];

  buildInputs = [
    libxkbcommon
    wayland
  ];

  postInstall = ''
    install -Dm 644 havoc.cfg -t $out/etc/havoc/
    install -Dm 644 README.md -t $out/share/doc/havoc-${finalAttrs.version}/
  '';

  depsBuildBuild = [
    pkg-config
  ];

  dontConfigure = true;
  enableParallelBuilding = true;
  installFlags = [ "PREFIX=$$out" ];

  meta = {
    inherit (wayland.meta) platforms;
    description = "Minimal terminal emulator for Wayland";
    homepage = "https://github.com/ii8/havoc";

    license = with lib.licenses; [
      mit
      publicDomain
    ];

    maintainers = with lib.maintainers; [ videl ];
    mainProgram = "havoc";
    broken = stdenv.hostPlatform.isDarwin; # fatal error: 'sys/epoll.h' file not found
  };
})
