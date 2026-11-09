# Aturan kerja

## Scene
- Satu scene dikerjakan oleh satu orang pada satu waktu. Cek pembagian tugas di bawah.
- Bagi dunia menjadi scene kecil, lalu instansiasi ke scene utama.
- Pindahkan atau ganti nama file lewat panel FileSystem di Godot.
- Sertakan file `.uid` saat commit. Jangan edit atau hapus file itu, dan jangan commit folder `.godot/`.
- Koordinasikan dengan grup sebelum mengubah `main_world.tscn`.

## Penamaan
- Nama file dan folder memakai `snake_case`; nama class dan node memakai `PascalCase`.
- Tulis nama variabel dan fungsi dalam Bahasa Inggris.

## Aset
- Utamakan aset CC0, misalnya dari Kenney. Catat sumber dan lisensinya di `LICENSES.md`.
- Aset biner dikelola dengan Git LFS. Jangan tambahkan file besar yang tidak dipakai.

## Pembagian tugas

| Area | Penanggung jawab | Scene atau folder |
|---|---|---|
| Dunia utama | ISI | `scenes/world/` |
| Cuaca (hujan dan angin) | ISI | `scenes/effects/` |
| Pencahayaan dan siklus siang-malam | ISI | `scripts/day_night_cycle.gd` |
| Props dan aset | ISI | `scenes/props/`, `assets/` |
| UI dan kamera | ISI | `scenes/ui/` |
