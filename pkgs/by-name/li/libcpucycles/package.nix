{
  lib,
  stdenv,
  fetchzip,
  librandombytes,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (librandombytes) hardeningDisable configurePlatforms env;
  pname = "libcpucycles";
  version = "20260105";

  src = fetchzip {
    url = "https://cpucycles.cr.yp.to/libcpucycles-${finalAttrs.version}.tar.gz";
    hash = "sha256-hWmMLBadM/E/kF8D/cTjU+G0f2HTkZQlKoIWsgzAFj0=";
  };

  patches = [ ./environment-variable-tools.patch ];

  postPatch = ''
    patchShebangs configure
    patchShebangs scripts-build
  '';

  nativeBuildInputs = [ python3 ];

  preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -id "$out/lib/libcpucycles.1.dylib" "$out/lib/libcpucycles.1.dylib"
    install_name_tool -change "libcpucycles.1.dylib" "$out/lib/libcpucycles.1.dylib" "$out/bin/cpucycles-info"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    inherit (librandombytes.meta) platforms;
    description = "Microlibrary for counting CPU cycles";
    homepage = "https://cpucycles.cr.yp.to/";
    changelog = "https://cpucycles.cr.yp.to/download.html";

    license = with lib.licenses; [
      # Upstream specifies the public domain licenses with the terms here https://cr.yp.to/spdx.html
      publicDomain
      cc0
      bsd0
      mit
      mit0
    ];

    maintainers = with lib.maintainers; [
      kiike
      imadnyc
      jleightcap
    ];
  };
})
