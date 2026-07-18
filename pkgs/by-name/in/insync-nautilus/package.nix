{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  nautilus-python,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "insync-nautilus";
  version = "3.9.5.60024";

  # Download latest from: https://www.insynchq.com/downloads/linux#nautilus
  src = fetchurl rec {
    hash = "sha256-yfPZ58xWZknpCqE8cJ7e7fR4+nzsCdprgBFRL0U0LvM=";

    urls = [
      "https://cdn.insynchq.com/builds/linux/${finalAttrs.version}/insync-nautilus_${finalAttrs.version}_all.deb"
      "https://web.archive.org/web/20250502162242/${builtins.elemAt urls 0}"
    ];
  };

  nativeBuildInputs = [ dpkg ];
  buildInputs = [ nautilus-python ];

  installPhase = ''
    runHook preInstall

    cp -r usr $out

    runHook postInstall
  '';

  pyproject = true;

  meta = {
    description = "This package contains the Python extension and icons for integrating Insync with Nautilus";
    homepage = "https://www.insynchq.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ hellwolf ];
    platforms = [ "x86_64-linux" ];
  };
})
