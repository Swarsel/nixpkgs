{
  lib,
  stdenv,
  common-updater-scripts,
  fetchzip,
  pcre2,
  writeShellApplication,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "geolite-legacy";
  version = "20260204";

  buildCommand = ''
    mkdir -p $out/share/GeoIP
    cp ${geoip}/usr/share/GeoIP/*.dat $out/share/GeoIP
    cp ${extra}/usr/share/GeoIP/*.dat $out/share/GeoIP
  '';

  extra = fetchzip {
    nativeBuildInputs = [ zstd ];
    hash = "sha256-L7uJtbkXD5H5bbZNsrFDzHwKZvhg/6fOwo0DM2Iuh9o=";
    stripRoot = false;
    url = "https://archive.archlinux.org/packages/g/geoip-database-extra/geoip-database-extra-${version}-1-any.pkg.tar.zst";
  };

  # We use Arch Linux package as a snapshot, because upstream database is updated in-place.
  geoip = fetchzip {
    nativeBuildInputs = [ zstd ];
    hash = "sha256-OJSBPAwzJO+qjjgQwpG7bsaJ8C4DpLMRbLMYfK+DSFA=";
    stripRoot = false;
    url = "https://archive.archlinux.org/packages/g/geoip-database/geoip-database-${version}-1-any.pkg.tar.zst";
  };

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-geolite-legacy";

      runtimeInputs = [
        common-updater-scripts
        pcre2
      ];

      text = ''
        url=https://archive.archlinux.org/packages/g/geoip-database/

        version=$(list-directory-versions --pname geoip-database --url $url |
                  pcre2grep -o1 '^(\d{8})-1-any\.pkg\.tar\.zst$' |
                  sort -n |
                  tail -1)

        for key in geoip extra; do
            update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=$key --ignore-same-version
        done
      '';
    });
  };

  meta = {
    description = "GeoLite Legacy IP geolocation databases";
    homepage = "https://mailfud.org/geoip-legacy/";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.all;
  };
}
