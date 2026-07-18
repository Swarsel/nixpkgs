{
  lib,
  skalibs,
  skawarePackages,
}:

skawarePackages.buildPackage {
  pname = "mdevd";
  version = "0.1.8.2";

  outputs = [
    "bin"
    "out"
    "dev"
    "doc"
  ];

  configureFlags = [
    "--with-sysdeps=${skalibs.lib}/lib/skalibs/sysdeps"
    "--with-include=${skalibs.dev}/include"
    "--with-lib=${skalibs.lib}/lib"
  ];

  postInstall = ''
    # remove all mdevd executables from build directory
    rm $(find -type f -mindepth 1 -maxdepth 1 -executable)
    rm libmdevd.*

    mv doc $doc/share/doc/mdevd/html
    mv examples $doc/share/doc/mdevd/examples
  '';

  description = "mdev-compatible Linux hotplug manager daemon";
  platforms = lib.platforms.linux;
  sha256 = "sha256-zhrgFJtqV6NPYIIY/WGBqmqmgTXKwvTZMbW0F7By4kQ=";
}
