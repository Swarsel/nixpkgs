{
  lib,
  stdenv,
  fetchurl,
  puredata,
  unzip,
}:

stdenv.mkDerivation {
  pname = "helmholtz";
  version = "1.0";

  src = fetchurl {
    url = "https://www.katjaas.nl/helmholtz/helmholtz~.zip";
    sha256 = "0h1fj7lmvq9j6rmw33rb8k0byxb898bi2xhcwkqalb84avhywgvs";
    curlOpts = "--user-agent ''";
    name = "helmholtz.zip";
  };

  nativeBuildInputs = [ unzip ];
  buildInputs = [ puredata ];

  installPhase = ''
    cp -r helmholtz~/ $out/
  '';

  patchPhase = ''
    mkdir -p $out/helmholtz~
    sed -i "s@current: pd_darwin@current: pd_linux@g" Makefile
    sed -i "s@-Wl@@g" Makefile
    sed -i "s@\$(NAME).pd_linux \.\./\$(NAME).pd_linux@helmholtz~.pd_linux $out/helmholtz~/@g" Makefile
  '';

  unpackPhase = ''
    unzip $src
    mv helmholtz~/src/helmholtz\~.cpp .
    mv helmholtz~/src/Helmholtz.cpp .
    mv helmholtz~/src/include/ .
    mv helmholtz~/src/Makefile .
    rm -rf helmholtz~/src/
    rm helmholtz~/helmholtz~.pd_darwin
    rm helmholtz~/helmholtz~.pd_linux
    rm helmholtz~/helmholtz~.dll
    rm -rf __MACOSX
  '';

  meta = {
    description = "Time domain pitch tracker for Pure Data";
    homepage = "http://www.katjaas.nl/helmholtz/helmholtz.html";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
}
