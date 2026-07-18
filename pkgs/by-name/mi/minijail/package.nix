{
  lib,
  stdenv,
  fetchFromGitiles,
  installShellFiles,
  libcap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minijail";
  version = "2026.05.18";

  src = fetchFromGitiles {
    url = "https://chromium.googlesource.com/chromiumos/platform/minijail";
    tag = "linux-v${finalAttrs.version}";
    hash = "sha256-15TQnTFIx2DSdAQZPCVhBPs8a+V6YV3IrA1LqfMWcRQ=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace /bin/echo echo
    patchShebangs platform2_preinstall.sh
  '';

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ libcap ];

  makeFlags = [
    "ECHO=echo"
    "LIBDIR=$(out)/lib"
  ];

  installPhase = ''
    ./platform2_preinstall.sh ${finalAttrs.version} $out/include/chromeos

    mkdir -p $out/lib/pkgconfig $out/include/chromeos $out/bin \
        $out/share/minijail

    cp -v *.so $out/lib
    cp -v *.pc $out/lib/pkgconfig
    cp -v libminijail.h scoped_minijail.h $out/include/chromeos
    cp -v minijail0 $out/bin

    installManPage minijail0.1 minijail0.5
  '';

  enableParallelBuilding = true;
  # causes redefinition of _FORTIFY_SOURCE
  hardeningDisable = [ "fortify3" ];

  meta = {
    description = "Sandboxing library and application using Linux namespaces and capabilities";
    homepage = "https://chromium.googlesource.com/chromiumos/platform/minijail/+/refs/heads/main/README.md";
    changelog = "https://chromium.googlesource.com/chromiumos/platform/minijail/+/refs/tags/linux-v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      pcarrier
      qyliss
    ];

    platforms = lib.platforms.linux;
    mainProgram = "minijail0";
  };
})
