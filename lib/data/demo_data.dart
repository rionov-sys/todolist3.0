import 'models/task.dart';

/// Offline-first seed data.
///
/// Used the first time the app runs (or whenever the backend is unreachable
/// and no cache exists), so every screen renders with realistic content that
/// matches the design mocks — including a completed task for each of the last
/// seven days to power the "7 Hari Streak" badge.
abstract final class DemoData {
  DemoData._();

  static int _seq = 0;

  static String _id() =>
      'demo_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  static Task _task({
    required String title,
    required String description,
    required TaskCategory category,
    required TaskStatus status,
    required int dayOffset,
    required String time,
    int estimate = 45,
    int progress = 0,
    bool priority = false,
    String? tag,
    String? meta,
    int points = 10,
  }) {
    final DateTime now = DateTime.now();
    return Task(
      id: _id(),
      title: title,
      description: description,
      category: category,
      status: status,
      date: DateTime(now.year, now.month, now.day + dayOffset),
      time: time,
      estimateMinutes: estimate,
      progress: progress,
      highPriority: priority,
      tag: tag,
      meta: meta,
      points: points,
    );
  }

  /// Builds the full demo set (relative to "today" so the weekly strip,
  /// streak and statistics are always populated).
  static List<Task> tasks() => <Task>[
        // ------------------------------------------------------------------
        // Today — mirrors the mocked "Tugas Hari Ini" + priority list
        // ------------------------------------------------------------------
        _task(
          title: 'Rapat Tim Produk',
          description:
              'Diskusi kelompok untuk perancangan fitur baru bersama tim produk.',
          category: TaskCategory.meeting,
          status: TaskStatus.inProgress,
          dayOffset: 0,
          time: '10:00',
          estimate: 45,
          progress: 48,
          priority: true,
          tag: 'Prioritas Tinggi',
        ),
        _task(
          title: 'Standup Pagi',
          description: 'Sinkronisasi singkat bersama tim soal progres harian.',
          category: TaskCategory.meeting,
          status: TaskStatus.done,
          dayOffset: 0,
          time: '08:30',
          estimate: 15,
          progress: 100,
          meta: 'Google Meet Room 2',
        ),
        _task(
          title: 'Wireframing Dasbor Mobile',
          description:
              'Buat sketsa low-fidelity dan susun arsitektur informasi halaman.',
          category: TaskCategory.wireframe,
          status: TaskStatus.todo,
          dayOffset: 0,
          time: '12:00',
          estimate: 45,
          tag: 'Desain',
        ),
        _task(
          title: 'Review Sistem Komponen Figma',
          description:
              'Validasi token warna, typography, dan padding bersama front-end dev.',
          category: TaskCategory.ui,
          status: TaskStatus.inProgress,
          dayOffset: 0,
          time: '13:30',
          estimate: 60,
          progress: 65,
          tag: 'Design System',
        ),
        _task(
          title: 'Usability Test Onboarding',
          description:
              'Wawancara dengan 5 user untuk evaluasi alur onboarding baru.',
          category: TaskCategory.dev,
          status: TaskStatus.inProgress,
          dayOffset: 0,
          time: '15:00',
          estimate: 50,
          progress: 25,
          tag: 'Riset',
        ),
        _task(
          title: 'Usability Testing Pengguna',
          description:
              'Pengujian pengguna primer terhadap prototipe baru dengan 5 partisipan.',
          category: TaskCategory.ui,
          status: TaskStatus.done,
          dayOffset: 0,
          time: '15:45',
          estimate: 45,
          progress: 100,
          meta: 'Google Meet Room 2',
        ),
        _task(
          title: 'Penyusunan Prototipe Interaktif',
          description:
              'Hubungkan micro-interaction pada navigasi bawah dan card switcher.',
          category: TaskCategory.ui,
          status: TaskStatus.todo,
          dayOffset: 0,
          time: '16:45',
          estimate: 90,
          tag: 'Prototipe',
        ),
        _task(
          title: 'Evaluasi & Sprint Review',
          description:
              'Rangkuman hasil uji coba bersama tim dan evaluasi sprint pekanan.',
          category: TaskCategory.meeting,
          status: TaskStatus.todo,
          dayOffset: 0,
          time: '16:30',
          estimate: 60,
          tag: 'Sprint',
          meta: 'Hasil dicatat di Notion',
        ),

        // ------------------------------------------------------------------
        // Past 6 days — one completed task per day keeps the streak at 7
        // ------------------------------------------------------------------
        _task(
          title: 'Sinkronisasi Desain Token',
          description: 'Samakan variabel warna antara Figma dan kode.',
          category: TaskCategory.ui,
          status: TaskStatus.done,
          dayOffset: -1,
          time: '14:00',
          estimate: 60,
          progress: 100,
        ),
        _task(
          title: 'Wireframe Alur Checkout',
          description: 'Susun alur checkout tiga langkah versi awal.',
          category: TaskCategory.wireframe,
          status: TaskStatus.done,
          dayOffset: -2,
          time: '11:00',
          estimate: 75,
          progress: 100,
        ),
        _task(
          title: 'Laporan Mingguan',
          description: 'Rekap progres dan hambatan minggu ini.',
          category: TaskCategory.meeting,
          status: TaskStatus.todo,
          dayOffset: -2,
          time: '17:00',
          estimate: 30,
        ),
        _task(
          title: 'Riset Kompetitor Aplikasi',
          description: 'Bandingkan fitur onboarding tiga kompetitor utama.',
          category: TaskCategory.ui,
          status: TaskStatus.done,
          dayOffset: -3,
          time: '10:30',
          estimate: 90,
          progress: 100,
        ),
        _task(
          title: 'Perapihan Kode Modul Auth',
          description: 'Refactor kecil agar alur login lebih mudah diuji.',
          category: TaskCategory.dev,
          status: TaskStatus.done,
          dayOffset: -4,
          time: '15:00',
          estimate: 60,
          progress: 100,
        ),
        _task(
          title: 'Sesi Diskusi Pengguna',
          description: 'Wawancara lanjutan untuk validasi hipotesis onboarding.',
          category: TaskCategory.meeting,
          status: TaskStatus.done,
          dayOffset: -5,
          time: '13:00',
          estimate: 45,
          progress: 100,
        ),
        _task(
          title: 'Audit Aksesibilitas',
          description: 'Cek kontras teks dan target sentuh pada layar utama.',
          category: TaskCategory.ui,
          status: TaskStatus.done,
          dayOffset: -6,
          time: '16:30',
          estimate: 50,
          progress: 100,
        ),

        // ------------------------------------------------------------------
        // Last week — gives the "+N% dr minggu lalu" trend a baseline
        // ------------------------------------------------------------------
        _task(
          title: 'Refleksi Sprint Lalu',
          description: 'Dokumentasikan pelajaran dari sprint sebelumnya.',
          category: TaskCategory.meeting,
          status: TaskStatus.done,
          dayOffset: -8,
          time: '09:30',
          estimate: 40,
          progress: 100,
        ),
        _task(
          title: 'Pengemasan Rilis Hotfix',
          description: 'Siapkan build hotfix untuk pengguna beta.',
          category: TaskCategory.dev,
          status: TaskStatus.todo,
          dayOffset: -8,
          time: '14:00',
          estimate: 60,
        ),
        _task(
          title: 'Survei Kepuasan Pengguna',
          description: 'Kirim dan kumpulkan 30 respons survei.',
          category: TaskCategory.ui,
          status: TaskStatus.done,
          dayOffset: -9,
          time: '11:00',
          estimate: 50,
          progress: 100,
        ),
        _task(
          title: 'Sketsa Ikon Baru',
          description: 'Eksplorasi tiga arah visual untuk ikon fitur.',
          category: TaskCategory.wireframe,
          status: TaskStatus.todo,
          dayOffset: -10,
          time: '13:30',
          estimate: 75,
        ),
        _task(
          title: 'Deploy Perbaikan Bug Kritis',
          description: 'Rilis perbaikan isu crash pada halaman jadwal.',
          category: TaskCategory.dev,
          status: TaskStatus.done,
          dayOffset: -10,
          time: '16:00',
          estimate: 45,
          progress: 100,
        ),

        // ------------------------------------------------------------------
        // Coming days this week
        // ------------------------------------------------------------------
        _task(
          title: 'Pengembangan Komponen Button',
          description: 'Implementasi seluruh varian tombol dari design system.',
          category: TaskCategory.dev,
          status: TaskStatus.todo,
          dayOffset: 1,
          time: '09:30',
          estimate: 120,
        ),
        _task(
          title: 'Wireframe Halaman Profil',
          description: 'Susun layout profil pengguna dan riwayat prestasi.',
          category: TaskCategory.wireframe,
          status: TaskStatus.todo,
          dayOffset: 1,
          time: '13:00',
          estimate: 60,
        ),
        _task(
          title: 'Integrasi API Kategori',
          description: 'Hubungkan daftar kategori dengan endpoint backend.',
          category: TaskCategory.dev,
          status: TaskStatus.inProgress,
          dayOffset: 2,
          time: '10:00',
          estimate: 90,
          progress: 35,
        ),
        _task(
          title: 'Presentasi Sprint ke Stakeholder',
          description: 'Paparkan hasil iterasi dan rencana rilis berikutnya.',
          category: TaskCategory.meeting,
          status: TaskStatus.todo,
          dayOffset: 2,
          time: '15:00',
          estimate: 60,
          priority: true,
        ),
        _task(
          title: 'Desain Ilustrasi Empty State',
          description: 'Buat ilustrasi ramah untuk layar data kosong.',
          category: TaskCategory.ui,
          status: TaskStatus.todo,
          dayOffset: 3,
          time: '11:00',
          estimate: 45,
        ),
        _task(
          title: 'QA Regresi Rilis 1.0',
          description: 'Jalankan checklist regresi di perangkat utama.',
          category: TaskCategory.dev,
          status: TaskStatus.todo,
          dayOffset: 4,
          time: '14:00',
          estimate: 120,
          meta: 'Checklist QA di Notion',
        ),
      ];
}