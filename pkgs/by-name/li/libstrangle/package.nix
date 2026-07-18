{
  lib,
  fetchFromGitLab,
  fetchpatch,
  libGL,
  libx11,
  stdenv_32bit,
}:

stdenv_32bit.mkDerivation {
  pname = "libstrangle";
  version = "unstable-202202022";

  src = fetchFromGitLab {
    owner = "torkel104";
    repo = "libstrangle";
    rev = "0273e318e3b0cc759155db8729ad74266b74cb9b";
    hash = "sha256-h10QA7m7hIQHq1g/vCYuZsFR2NVbtWBB46V6OWP5wgM=";
  };

  patches = [
    ./nixos.patch
    # Pull the fix pending upstream inclusion for gcc-13:
    #   https://gitlab.com/torkel104/libstrangle/-/merge_requests/29
    (fetchpatch {
      hash = "sha256-AKMHAZhCPcn62pi4fBGhw2r8SNSkCDMUCpR3IlmJ7wQ=";
      name = "gcc-13.patch";
      url = "https://gitlab.com/torkel104/libstrangle/-/commit/4e17025071de1d99630febe7270b4f63056d0dfa.patch";
    })
  ];

  postPatch = ''
    substituteAllInPlace src/strangle.sh
    substituteAllInPlace src/stranglevk.sh
  '';

  buildInputs = [
    libGL
    libx11
  ];

  makeFlags = [
    "prefix="
    "DESTDIR=$(out)"
  ];

  postInstall = ''
    substitute $out/share/vulkan/implicit_layer.d/libstrangle_vk.json $out/share/vulkan/implicit_layer.d/libstrangle_vk.x86.json \
      --replace "libstrangle_vk.so" "$out/lib/libstrangle/lib32/libstrangle_vk.so"
    substituteInPlace $out/share/vulkan/implicit_layer.d/libstrangle_vk.json \
      --replace "libstrangle_vk.so" "$out/lib/libstrangle/lib64/libstrangle_vk.so"
  '';

  meta = {
    description = "Frame rate limiter for Linux/OpenGL";
    homepage = "https://gitlab.com/torkel104/libstrangle";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ aske ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "strangle";
  };
}
