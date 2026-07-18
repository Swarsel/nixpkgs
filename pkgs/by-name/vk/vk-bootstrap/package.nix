{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2_3,
  cmake,
  glfw,
  vulkan-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vk-bootstrap";
  version = "1.4.350";

  src = fetchFromGitHub {
    owner = "charles-lunarg";
    repo = "vk-bootstrap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HAoEsWwc12lcpEl5gNz4EN0cvjZcg5jsnEBodiDj+1c=";
  };

  patches = [
    ./0001-disable-fetch-content.patch
    ./0002-fix-install-tests.patch
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    vulkan-headers
  ];

  cmakeFlags = [
    "-DVK_BOOTSTRAP_INSTALL=1"
  ];

  doCheck = true;

  checkInputs = [
    glfw
    catch2_3
  ];

  meta = {
    description = "Vulkan Bootstrapping Library";
    homepage = "https://github.com/charles-lunarg/vk-bootstrap";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
