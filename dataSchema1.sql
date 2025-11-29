-- Table: User
CREATE TABLE user (
    user_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email_address VARCHAR(100) NOT NULL UNIQUE
    CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    phone_number VARCHAR(20) NOT NULL UNIQUE
    CHECK (phone_number ~* '^\+?[0-9]{10,15}$'),
    last_login TIMESTAMP
    CHECK (last_login <= CURRENT_TIMESTAMP)
);

-- Table: Location
CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY,
    location_name VARCHAR(50) NOT NULL,
    location_type VARCHAR(30)
    CHECK (location_type IN ('Житлова', 'Офіс', 'Склад')),
    building VARCHAR(50),
    floor INTEGER,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

-- Table: Monitoring (base)
CREATE TABLE monitorings (
    monitoring_id INTEGER PRIMARY KEY,
    monitoring_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Неактивний'
    CHECK (status IN ('Активний', 'Неактивний')),
    installation_date DATE NOT NULL
    CHECK (installation_date <= CURRENT_DATE),
    data_collection_frequency INTERVAL NOT NULL
    CHECK (data_collection_frequency > INTERVAL '0 second'),
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

-- Table: TemperatureMonitoring
CREATE TABLE temperature_monitoring (
    temp_monitoring_id INTEGER PRIMARY KEY,
    lower_limit NUMERIC(5, 2) NOT NULL
    CHECK (lower_limit > -100),
    upper_limit NUMERIC(5, 2) NOT NULL
    CHECK (upper_limit < 200),
    monitoring_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (monitoring_id) REFERENCES monitorings (
        monitoring_id
    ) ON DELETE CASCADE
);

-- Table: SecurityMonitoring
CREATE TABLE security_monitoring (
    security_monitoring_id INTEGER PRIMARY KEY,
    risk_priority VARCHAR(30) NOT NULL
    CHECK (risk_priority IN ('Низький', 'Середній', 'Високий')),
    risk_types VARCHAR(50) NOT NULL
    CHECK (risk_types IN ('Якість повітря', 'Задимлення', 'Рух')),
    monitoring_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (monitoring_id) REFERENCES monitorings (
        monitoring_id
    ) ON DELETE CASCADE
);

-- Table: Sensor
CREATE TABLE sensor (
    sensor_id INTEGER PRIMARY KEY,
    sensor_name VARCHAR(50) NOT NULL UNIQUE,
    sensor_type VARCHAR(30) NOT NULL
    CHECK (sensor_type IN ('Температура', 'CO2', 'Дим', 'Рух')),
    manufacturer VARCHAR(50),
    model_ver VARCHAR(50),
    location_id INTEGER NOT NULL,
    monitoring_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations (location_id),
    FOREIGN KEY (monitoring_id) REFERENCES monitorings (monitoring_id)
);

-- Table: CurrentTemperature
CREATE TABLE current_temperature (
    curr_temp_id INTEGER PRIMARY KEY,
    curr_value NUMERIC(5, 2) NOT NULL,
    last_update TIMESTAMP NOT NULL
    CHECK (last_update <= CURRENT_TIMESTAMP),
    temp_monitoring_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (temp_monitoring_id) REFERENCES temperature_monitoring (
        temp_monitoring_id
    ) ON DELETE CASCADE
);

-- Table: CurrentSecurityStatus
CREATE TABLE current_security_status (
    curr_sec_id INTEGER PRIMARY KEY,
    overall_status VARCHAR(30) NOT NULL
    CHECK (overall_status IN ('Безпечно', 'Загроза')),
    last_update TIMESTAMP NOT NULL
    CHECK (last_update <= CURRENT_TIMESTAMP),
    security_monitoring_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (security_monitoring_id) REFERENCES security_monitoring (
        security_monitoring_id
    ) ON DELETE CASCADE
);

-- Table: Notification
CREATE TABLE notification (
    notification_id INTEGER PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    date_time TIMESTAMP NOT NULL
    CHECK (date_time <= CURRENT_TIMESTAMP),
    event_category VARCHAR(50) NOT NULL
    CHECK (event_category IN ('Температура', 'Безпека')),
    monitoring_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (monitoring_id) REFERENCES monitorings (monitoring_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

-- Indexes
CREATE INDEX idx_monitoring_user ON monitorings (user_id);
CREATE INDEX idx_tempmon_monitoring ON temperature_monitoring (monitoring_id);
CREATE INDEX idx_secmon_monitoring ON security_monitoring (monitoring_id);
CREATE INDEX idx_currtemp_monitoring ON current_temperature (
    temp_monitoring_id
);
CREATE INDEX idx_currsec_monitoring ON current_security_status (
    security_monitoring_id
);
CREATE INDEX idx_notif_monitoring ON notification (monitoring_id);
CREATE INDEX idx_notif_user ON notification (user_id);
CREATE INDEX idx_sensor_location ON sensor (location_id);
CREATE INDEX idx_sensor_monitoring ON sensor (monitoring_id);
CREATE INDEX idx_location_user ON locations (user_id);
