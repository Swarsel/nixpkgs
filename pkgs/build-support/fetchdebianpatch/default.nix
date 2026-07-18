{ lib, fetchpatch }:

lib.makeOverridable (
  {
    hash,
    patch,
    pname,
    version,
    area ? "main",
    debianRevision ? null,
    name ? patch,
  }:
  let
    inherit (lib.strings) hasPrefix substring;
    prefix = substring 0 (if hasPrefix "lib" pname then 4 else 1) pname;
    versionString = if debianRevision == null then version else "${version}-${debianRevision}";
  in
  fetchpatch {
    inherit name hash;

    url =
      "https://sources.debian.org/data/${area}/${prefix}/"
      + "${pname}/${versionString}/debian/patches/${patch}";
  }
)
