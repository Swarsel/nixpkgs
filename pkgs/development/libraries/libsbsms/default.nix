let
  pname = "libsbsms";
in
pkgs: rec {
  libsbsms = libsbsms_2_0_2;

  libsbsms_2_0_2 = pkgs.callPackage ./common.nix rec {
    inherit pname;
    version = "2.0.2";
    homepage = "https://sourceforge.net/projects/sbsms/files/sbsms";
    sha256 = "sha256-zqs9lwZkszcFe0a89VKD1Q0ynaY2v4PQ7nw24iNBru4=";
    url = "mirror://sourceforge/sbsms/${pname}-${version}.tar.gz";
  };

  libsbsms_2_3_0 = pkgs.callPackage ./common.nix rec {
    inherit pname;
    version = "2.3.0";
    homepage = "https://github.com/claytonotey/libsbsms";
    sha256 = "sha256-T4jRUrwG/tvanV1lUX1AJUpzEMkFBgGpMSIwnUWv0sk=";
    url = "https://github.com/claytonotey/${pname}/archive/refs/tags/${version}.tar.gz";
  };
}
