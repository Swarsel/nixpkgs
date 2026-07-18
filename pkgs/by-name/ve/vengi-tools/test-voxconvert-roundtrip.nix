{
  stdenv,
  vengi-tools,
}:

stdenv.mkDerivation {
  buildCommand = ''
    ${vengi-tools}/bin/vengi-voxconvert --input ${vengi-tools.src}/data/tests/chr_knight.qb --output chr_knight.vox
    ${vengi-tools}/bin/vengi-voxconvert --input chr_knight.vox --output chr_knight.qb
    ${vengi-tools}/bin/vengi-voxconvert --input chr_knight.qb --output chr_knight1.vox
    diff chr_knight.vox chr_knight1.vox
    touch $out
  '';

  name = "vengi-tools-test-voxconvert-roundtrip";
  meta.timeout = 10;
}
