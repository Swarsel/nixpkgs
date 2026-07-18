{
  lib,
  stdenv,
  gmp,
  idris2-src,
  idris2-version,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libidris2_support";
  version = idris2-version;
  src = idris2-src;
  strictDeps = true;
  buildInputs = [ gmp ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "OS=";

  buildFlags = [ "support" ];

  postInstall = ''
    mv "$out/idris2-${finalAttrs.version}/lib" "$out/lib"
    mv "$out/idris2-${finalAttrs.version}/support" "$out/share"
    rm -rf $out/idris2-${finalAttrs.version}
  '';

  enableParallelBuilding = true;
  installTargets = "install-support";
  meta.description = "Runtime library for Idris2";
})
