{
  lib,
  stdenv,
  fetchFromGitLab,
  alsa-lib,
  bzip2,
  cmake,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  openssl,
  patchelf,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  wayland,
  wayland-protocols,
  writeShellScript,
}:
let
  version = "0.17.0";
  # Patch for airshipper to install veloren
  patch =
    let
      runtimeLibs = [
        udev
        alsa-lib
        (lib.getLib stdenv.cc.cc)
        libxkbcommon
        libxcb
        libx11
        libxcursor
        libxrandr
        libxi
        vulkan-loader
        libGL
      ];
    in
    writeShellScript "patch" ''
      echo "making binaries executable"
      chmod +x {veloren-voxygen,veloren-server-cli}
      echo "patching dynamic linkers"
      ${patchelf}/bin/patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        veloren-server-cli
      ${patchelf}/bin/patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${lib.makeLibraryPath runtimeLibs}" \
        veloren-voxygen
    '';
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "airshipper";

  src = fetchFromGitLab {
    owner = "Veloren";
    repo = "airshipper";
    tag = "v${version}";
    hash = "sha256-M89RswC08MZnNfk2T1+rtDajTpDGTnJoZ2U8bU5U2+0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    openssl
    wayland
    wayland-protocols
    libxkbcommon
    libx11
    libxrandr
    libxi
    libxcursor
  ];

  cargoHash = "sha256-ry0hFvMDnotDQu6mqgyt+6hKOvGRJLmZKs3SxEVtDRg=";
  env.RUSTC_BOOTSTRAP = 1; # We need rust unstable features
  doCheck = false;

  postInstall = ''
    install -Dm444 -t "$out/share/applications" "client/assets/net.veloren.airshipper.desktop"
    install -Dm444    "client/assets/net.veloren.airshipper.png"  "$out/share/icons/net.veloren.airshipper.png"
  '';

  postFixup =
    let
      libPath = lib.makeLibraryPath [
        libGL
        vulkan-loader
        wayland
        wayland-protocols
        bzip2
        fontconfig
        freetype
        libxkbcommon
        libx11
        libxrandr
        libxi
        libxcursor
      ];
    in
    ''
      # We set LD_LIBRARY_PATH instead of using patchelf in order to propagate the libs
      # to both Airshipper itself as well as the binaries downloaded by Airshipper.
      wrapProgram "$out/bin/airshipper" \
        --set VELOREN_PATCHER "${patch}" \
        --prefix LD_LIBRARY_PATH : "${libPath}"
    '';

  cargoBuildFlags = [
    "--package"
    "airshipper"
  ];

  cargoTestFlags = [
    "--package"
    "airshipper"
  ];

  meta = {
    description = "Provides automatic updates for the voxel RPG Veloren";
    homepage = "https://www.veloren.net";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ yusdacra ];
    mainProgram = "airshipper";
  };
}
