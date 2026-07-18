{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libiconv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "htmlcxx";
  version = "0.87";

  src = fetchurl {
    url = "mirror://sourceforge/htmlcxx/v${finalAttrs.version}/htmlcxx-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-XTj5OM9N+aKYpTRq8nGV//q/759GD8KgIjPLz6j8dcg=";
  };

  patches = [
    ./ptrdiff.patch
    ./c++17.patch
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libiconv ];

  meta = {
    description = "Simple non-validating css1 and html parser for C++";
    homepage = "https://htmlcxx.sourceforge.net/";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.all;
    mainProgram = "htmlcxx";
  };
})
