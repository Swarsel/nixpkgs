{
  stdenv,
  mdk-sdk,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "fvp";

  postPatch = ''
    sed -i 's|.*libc++.so.1.*|${mdk-sdk}/lib/libc++.so.1|' ./linux/CMakeLists.txt
    substituteInPlace ./linux/CMakeLists.txt \
      --replace-fail "fvp_setup_deps()" "include(${mdk-sdk}/lib/cmake/FindMDK.cmake)"
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}
