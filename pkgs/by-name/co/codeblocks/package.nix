{
  lib,
  stdenv,
  fetchurl,
  boost187,
  fetchpatch,
  file,
  gtk3,
  hunspell,
  pkg-config,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zip,
  contribPlugins ? false,
}:
let
  boost' = boost187;
in
stdenv.mkDerivation rec {
  pname = "codeblocks";
  version = "25.03";

  src = fetchurl {
    url = "mirror://sourceforge/codeblocks/Sources/${version}/codeblocks_${version}.tar.xz";
    hash = "sha256-sPaqWQjTNtf0H5V2skGKx9J++8WSgqqMkXHYjOp0BJ4=";
  };

  patches = [ ./writable-projects.patch ];

  nativeBuildInputs = [
    pkg-config
    file
    zip
    wrapGAppsHook3
  ];

  buildInputs = [
    wxwidgets_3_2
    gtk3
  ]
  ++ lib.optionals contribPlugins [
    hunspell
    boost'
  ];

  configureFlags = [
    "--enable-pch=no"
  ]
  ++ lib.optionals contribPlugins [
    (
      "--with-contrib-plugins=all,-FileManager"
      + lib.optionalString stdenv.hostPlatform.isDarwin ",-NassiShneiderman"
    )
    "--with-boost-libdir=${boost'}/lib"
  ];

  preConfigure = "substituteInPlace ./configure --replace-fail /bin/file ${file}/bin/file";
  postConfigure = lib.optionalString stdenv.hostPlatform.isLinux "substituteInPlace libtool --replace ldconfig ${stdenv.cc.libc.bin}/bin/ldconfig";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -s $out/lib/codeblocks/plugins $out/share/codeblocks/plugins
  '';

  enableParallelBuilding = true;
  name = "${pname}-${lib.optionalString contribPlugins "full-"}${version}";

  meta = {
    description = "Open source, cross platform, free C, C++ and Fortran IDE";

    longDescription = ''
      Code::Blocks is a free C, C++ and Fortran IDE built to meet the most demanding needs of its users.
      It is designed to be very extensible and fully configurable.
      Finally, an IDE with all the features you need, having a consistent look, feel and operation across platforms.
    '';

    homepage = "http://www.codeblocks.org";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
