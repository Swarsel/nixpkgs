{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  freetype-py,
  imageio,
  mesa,
  networkx,
  numpy,
  pillow,
  pyglet,
  pyopengl,
  pytestCheckHook,
  scipy,
  setuptools,
  six,
  trimesh,
}:

buildPythonPackage rec {
  pname = "pyrender";
  version = "0.1.45";

  src = fetchFromGitHub {
    owner = "mmatl";
    repo = "pyrender";
    tag = version;
    hash = "sha256-V2G8QWXMxFDQpT4XDOJhIFI2V9VhDQCaXYBb/QVLxgM=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-SXRV9RC3PfQGjjIQ+n97HZrSDPae3rAHnTBiHXSFLaY=";
      # yet to be tagged
      name = "relax-pyopengl.patch";
      url = "https://github.com/mmatl/pyrender/commit/7c613e8aed7142df9ff40767a8f10b7a19b6255c.patch";
    })
    # fix on numpy 2.0 (np.infty -> np.inf)
    # https://github.com/mmatl/pyrender/pull/292
    (fetchpatch {
      hash = "sha256-RIv6lMpxMmops5Tb1itzYdT7GkhPScVWslBXITR3IBM=";
      name = "fix-numpy2.patch";
      url = "https://github.com/mmatl/pyrender/commit/5408c7b45261473511d2399ab625efe11f0b6991.patch";
    })
  ];

  # trimesh too new
  # issue: https://github.com/mmatl/pyrender/issues/203
  # mega pr: https://github.com/mmatl/pyrender/pull/216
  # relevant pr commit: https://github.com/mmatl/pyrender/pull/216/commits/5069aeb957addff8919f05dc9be4040f55bff329
  # the commit does not apply as a patch when cherry picked, hence the substituteInPlace
  postPatch = ''
    substituteInPlace tests/unit/test_meshes.py \
      --replace-fail \
        "bm = trimesh.load('tests/data/WaterBottle.glb').dump()[0]" \
        'bm = trimesh.load("tests/data/WaterBottle.glb").geometry["WaterBottle"]'
  '';

  nativeBuildInputs = [ setuptools ];
  env.PYOPENGL_PLATFORM = "egl"; # enables headless rendering during check

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.filter (lib.meta.availableOn stdenv.hostPlatform) [
    mesa.llvmpipeHook
  ];

  dependencies = [
    freetype-py
    imageio
    networkx
    numpy
    pillow
    pyglet
    pyopengl
    scipy
    six
    trimesh
  ];

  disabledTestPaths = lib.optionals (!lib.meta.availableOn stdenv.hostPlatform mesa.llvmpipeHook) [
    # requires opengl context
    "tests/unit/test_offscreen.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyrender" ];

  meta = {
    description = "Easy-to-use glTF 2.0-compliant OpenGL renderer for visualization of 3D scenes";
    homepage = "https://pyrender.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
