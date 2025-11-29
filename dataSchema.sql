CREATE TABLE User (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE Sensor (
    id INT PRIMARY KEY,
    temperature FLOAT,
    alertStatus VARCHAR(100),
    location VARCHAR(255)
);

CREATE TABLE SafetyModule (
    id INT PRIMARY KEY,
    message TEXT,
    alertStatus VARCHAR(100)
);

CREATE TABLE SystemController (
    id INT PRIMARY KEY,
    mode VARCHAR(50),
    updateInterval INT,
    progress FLOAT
);

CREATE TABLE CreativityModule (
    id INT PRIMARY KEY,
    modelName VARCHAR(255),
    progress FLOAT
);

CREATE TABLE Feedback (
    id INT PRIMARY KEY,
    value FLOAT,
    date DATE,
    userId INT,
    FOREIGN KEY (userId) REFERENCES User(id)
);

CREATE TABLE DataRecord (
    id INT PRIMARY KEY,
    timestamp DATE,
    userId INT,
    FOREIGN KEY (userId) REFERENCES User(id)
);

CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_feedback_userid ON Feedback(userId);
CREATE INDEX idx_datarecord_userid ON DataRecord(userId);
CREATE INDEX idx_sensor_location ON Sensor(location);
CREATE INDEX idx_systemcontroller_mode ON SystemController(mode);
