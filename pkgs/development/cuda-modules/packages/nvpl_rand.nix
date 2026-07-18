{ buildRedist }:
buildRedist {
  pname = "nvpl_rand";

  outputs = [
    "out"
    "dev"
    "include"
    "lib"
  ];

  redistName = "nvpl";

  meta = {
    description = "Collection of efficient pseudorandom and quasirandom number generators for ARM CPUs";
    homepage = "https://developer.nvidia.com/nvpl";
    changelog = "https://docs.nvidia.com/nvpl/latest/rand/release_notes.html";
  };
}
