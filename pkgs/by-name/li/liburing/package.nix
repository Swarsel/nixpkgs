{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liburing";
  version = "2.14";

  src = fetchFromGitHub {
    owner = "axboe";
    repo = "liburing";
    tag = "liburing-${finalAttrs.version}";
    hash = "sha256-bSq4M28JRND4bdaIv/KXcCDB35cYM7gra1GVO3poWfc=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
    "man"
  ];

  configureFlags = [
    "--includedir=${placeholder "dev"}/include"
    "--mandir=${placeholder "man"}/share/man"
  ];

  postInstall = ''
    # Always builds both static and dynamic libraries, so we need to remove the
    # libraries that don't match stdenv type.
    rm $out/lib/liburing*${if stdenv.hostPlatform.isStatic then ".so*" else ".a"}

    # Copy the examples into $bin. Most reverse dependency of
    # this package should reference only the $out output
    for file in $(find ./examples -executable -type f); do
      install -Dm555 -t "$bin/bin" "$file"
    done
  '';

  # Doesn't recognize platform flags
  configurePlatforms = [ ];
  dontAddStaticConfigureFlags = true;
  dontDisableStatic = true;
  enableParallelBuilding = true;
  # mysterious link failure
  hardeningDisable = [ "trivialautovarinit" ];
  separateDebugInfo = true;
  # Upstream's configure script is not autoconf generated, but a hand written one.
  setOutputFlags = false;

  meta = {
    description = "Userspace library for the Linux io_uring API";
    homepage = "https://github.com/axboe/liburing";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      thoughtpolice
      nickcao
    ];

    platforms = lib.platforms.linux;
  };
})
