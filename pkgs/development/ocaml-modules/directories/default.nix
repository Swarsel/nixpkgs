{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  fpath,
}:

buildDunePackage (finalAttrs: {
  pname = "directories";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "directories";
    tag = finalAttrs.version;
    hash = "sha256-6qPdHqkZ0xREOTFOe5sGfz2ysDX+9JZDrEmJvenBcqw=";
  };

  propagatedBuildInputs = [
    fpath
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "OCaml library that provides configuration, cache and data paths (and more!) following the suitable conventions on Linux, macOS and Windows";

    longDescription = ''
      directories is an OCaml library that provides configuration, cache and
      data paths (and more!) following the suitable conventions on Linux, macOS
      and Windows. It is inspired by similar libraries for other languages such
      as directories-jvm.

      The following conventions are used: XDG Base Directory Specification and
      xdg-user-dirs on Linux, Known Folders on Windows, Standard Directories on
      macOS.
    '';

    homepage = "https://github.com/OCamlPro/directories";
    changelog = "https://raw.githubusercontent.com/OCamlPro/directories/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      bcc32
      redianthus
    ];
  };
})
