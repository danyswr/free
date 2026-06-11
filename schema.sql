-- =========================================================
-- 1. MASTER TABLES (Tabel Referensi)
-- =========================================================

CREATE TABLE role (
    id_role VARCHAR(50) PRIMARY KEY,
    nama_role VARCHAR(100) NOT NULL
);

CREATE TABLE pic (
    id_pic VARCHAR(50) PRIMARY KEY,
    nama_pic VARCHAR(255) NOT NULL
);

CREATE TABLE nama_dokter (
    id_dokter VARCHAR(50) PRIMARY KEY,
    nama_dokter VARCHAR(255) NOT NULL
);

CREATE TABLE lead_source (
    id_source VARCHAR(50) PRIMARY KEY,
    nama_source VARCHAR(255) NOT NULL
);

CREATE TABLE treatment_type (
    id_treatment VARCHAR(50) PRIMARY KEY,
    nama_treatment VARCHAR(255) NOT NULL
);

CREATE TABLE chat_status (
    id_chat VARCHAR(50) PRIMARY KEY,
    nama_status VARCHAR(100) NOT NULL
);

CREATE TABLE status_kunjungan (
    id_status VARCHAR(50) PRIMARY KEY,
    nama_status VARCHAR(100) NOT NULL
);

CREATE TABLE nama_sales (
    id_sales VARCHAR(50) PRIMARY KEY,
    nama_sales VARCHAR(255) NOT NULL
);

CREATE TABLE nama_kasir (
    id_namakasir VARCHAR(50) PRIMARY KEY,
    nama_kasir VARCHAR(255) NOT NULL
);

CREATE TABLE type_lensa (
    id_lensa VARCHAR(50) PRIMARY KEY,
    tipe_lensa VARCHAR(100) NOT NULL
);

CREATE TABLE method_payment (
    id_payment VARCHAR(50) PRIMARY KEY,
    jenis_payment VARCHAR(100) NOT NULL
);

CREATE TABLE jenis_kunjungan (
    id_kunjungan VARCHAR(50) PRIMARY KEY,
    jenis_kunjungan VARCHAR(255) NOT NULL
);

CREATE TABLE pipeline_status (
    id_pipeline VARCHAR(50) PRIMARY KEY,
    pipeline_name VARCHAR(100) NOT NULL
);

-- =========================================================
-- 2. USER & SYSTEM TABLES
-- =========================================================

CREATE TABLE account (
    id_user VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    id_role VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    ip_device VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_role) REFERENCES role(id_role) ON DELETE SET NULL
);

CREATE TABLE audit_log (
    id_log VARCHAR(50) PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_user VARCHAR(100), 
    ip_address VARCHAR(50),
    action VARCHAR(255),
    user_agent TEXT,
    endpoint_url TEXT,
    method VARCHAR(10),
    status_code INT
);

-- =========================================================
-- 3. CORE / TRANSACTIONAL TABLES (WITH SOFT DELETES & TIMESTAMPS)
-- =========================================================

CREATE TABLE data_pasien (
    id_pasien VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    usia INT,
    date_of_birth DATE,
    nik VARCHAR(50),
    gender VARCHAR(20),
    phone_number VARCHAR(50),
    alamat TEXT,
    email VARCHAR(255),
    id_source VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL, -- Soft delete flag
    FOREIGN KEY (id_source) REFERENCES lead_source(id_source) ON DELETE SET NULL
);

CREATE TABLE data_leads (
    id_leads VARCHAR(50) PRIMARY KEY,
    id_sales VARCHAR(50),
    id_pasien VARCHAR(50) NOT NULL,
    id_source VARCHAR(50),
    id_status VARCHAR(50),
    keterangan_status TEXT,
    is_screening BOOLEAN DEFAULT FALSE,
    is_tindakan BOOLEAN DEFAULT FALSE,
    id_chat VARCHAR(50),
    id_pipeline VARCHAR(50),
    chat_created_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (id_sales) REFERENCES nama_sales(id_sales) ON DELETE SET NULL,
    FOREIGN KEY (id_pasien) REFERENCES data_pasien(id_pasien) ON DELETE CASCADE,
    FOREIGN KEY (id_source) REFERENCES lead_source(id_source) ON DELETE SET NULL,
    FOREIGN KEY (id_status) REFERENCES status_kunjungan(id_status) ON DELETE SET NULL,
    FOREIGN KEY (id_chat) REFERENCES chat_status(id_chat) ON DELETE SET NULL,
    FOREIGN KEY (id_pipeline) REFERENCES pipeline_status(id_pipeline) ON DELETE SET NULL
);

-- NEW TABLE: Melacak riwayat perubahan pipeline/status untuk kebutuhan ML/Analitik
CREATE TABLE leads_status_history (
    id_history INT AUTO_INCREMENT PRIMARY KEY,
    id_leads VARCHAR(50) NOT NULL,
    old_pipeline VARCHAR(50),
    new_pipeline VARCHAR(50),
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_leads) REFERENCES data_leads(id_leads) ON DELETE CASCADE
);

CREATE TABLE appointment_form (
    id_appointment VARCHAR(50) PRIMARY KEY,
    id_pasien VARCHAR(50) NOT NULL,
    id_treatment VARCHAR(50),
    screening_date DATETIME,
    glasses_prescription TEXT,
    id_lensa VARCHAR(50),
    record_date DATE,
    id_source VARCHAR(50),
    is_done BOOLEAN DEFAULT FALSE,
    is_ai BOOLEAN DEFAULT FALSE, 
    id_pic VARCHAR(50),
    keterangan TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (id_pasien) REFERENCES data_pasien(id_pasien) ON DELETE CASCADE,
    FOREIGN KEY (id_treatment) REFERENCES treatment_type(id_treatment) ON DELETE SET NULL,
    FOREIGN KEY (id_lensa) REFERENCES type_lensa(id_lensa) ON DELETE SET NULL,
    FOREIGN KEY (id_source) REFERENCES lead_source(id_source) ON DELETE SET NULL,
    FOREIGN KEY (id_pic) REFERENCES pic(id_pic) ON DELETE SET NULL
);

CREATE TABLE laporan_kasir (
    id_laporankasir VARCHAR(50) PRIMARY KEY,
    id_pasien VARCHAR(50) NOT NULL,
    id_status VARCHAR(50),
    id_kunjungan VARCHAR(50),
    id_dokter VARCHAR(50),
    alasan_rujuk TEXT,
    biaya_tagihan DECIMAL(15,2) DEFAULT 0.00,
    obat TEXT,
    revenue DECIMAL(15,2) DEFAULT 0.00,
    down_payment DECIMAL(15,2) DEFAULT 0.00,
    refund DECIMAL(15,2) DEFAULT 0.00,
    id_payment VARCHAR(50),
    id_namakasir VARCHAR(50),
    keterangan TEXT,
    id_source VARCHAR(50),
    lead_dmy DATE,
    js_mt VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (id_pasien) REFERENCES data_pasien(id_pasien) ON DELETE CASCADE,
    FOREIGN KEY (id_status) REFERENCES status_kunjungan(id_status) ON DELETE SET NULL,
    FOREIGN KEY (id_kunjungan) REFERENCES jenis_kunjungan(id_kunjungan) ON DELETE SET NULL,
    FOREIGN KEY (id_dokter) REFERENCES nama_dokter(id_dokter) ON DELETE SET NULL,
    FOREIGN KEY (id_payment) REFERENCES method_payment(id_payment) ON DELETE SET NULL,
    FOREIGN KEY (id_namakasir) REFERENCES nama_kasir(id_namakasir) ON DELETE SET NULL,
    FOREIGN KEY (id_source) REFERENCES lead_source(id_source) ON DELETE SET NULL
);

-- =========================================================
-- 4. DATABASE TRIGGERS
-- =========================================================

DELIMITER //

-- TRIGGER 1: Mencatat riwayat setiap ada perubahan status/pipeline pada tabel LEADS
CREATE TRIGGER trg_lead_status_history
AFTER UPDATE ON data_leads
FOR EACH ROW
BEGIN
    -- Cek jika status pipeline atau status kunjungan berubah
    IF (OLD.id_pipeline != NEW.id_pipeline) OR (OLD.id_status != NEW.id_status) THEN
        INSERT INTO leads_status_history (
            id_leads, old_pipeline, new_pipeline, old_status, new_status
        ) VALUES (
            NEW.id_leads, OLD.id_pipeline, NEW.id_pipeline, OLD.id_status, NEW.id_status
        );
    END IF;
END //

-- TRIGGER 2: Auto Update `is_tindakan` di Data Leads saat ada transaksi Kasir masuk
CREATE TRIGGER trg_auto_tindakan_kasir
AFTER INSERT ON laporan_kasir
FOR EACH ROW
BEGIN
    -- Jika revenue lebih dari 0, otomatis tandai lead pasien tersebut sebagai sudah 'tindakan'
    IF NEW.revenue > 0 THEN
        UPDATE data_leads 
        SET is_tindakan = TRUE 
        WHERE id_pasien = NEW.id_pasien 
          AND is_tindakan = FALSE;
    END IF;
END //

DELIMITER ;

-- =========================================================
-- 5. INDEX OPTIMIZATION
-- =========================================================
CREATE INDEX idx_pasien_phone ON data_pasien(phone_number);
CREATE INDEX idx_leads_created ON data_leads(created_at);
CREATE INDEX idx_kasir_created ON laporan_kasir(created_at);
CREATE INDEX idx_kasir_revenue ON laporan_kasir(revenue);
CREATE INDEX idx_leads_history ON leads_status_history(id_leads, changed_at);