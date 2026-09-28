-- Hotel Booking System

CREATE TABLE hotels (
    hotel_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    city        VARCHAR(50)  NOT NULL,
    star_rating SMALLINT     NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
    phone       VARCHAR(20)
);

CREATE TABLE guests (
    guest_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(254) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    passport_number VARCHAR(20)  UNIQUE
);

CREATE TABLE services (
    service_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description TEXT,
    price       NUMERIC(8,2)  NOT NULL CHECK (price >= 0)
);

-- Weak entity: owned by hotels
CREATE TABLE rooms (
    hotel_id        INTEGER       NOT NULL
                    REFERENCES hotels(hotel_id)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE,
    room_number     VARCHAR(10)   NOT NULL,
    room_type       VARCHAR(20)   NOT NULL
                    CHECK (room_type IN ('single', 'double', 'suite', 'family')),
    floor           SMALLINT      NOT NULL CHECK (floor >= 0),
    price_per_night NUMERIC(8,2)  NOT NULL CHECK (price_per_night > 0),
    has_balcony     BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY (hotel_id, room_number)
);

CREATE TABLE bookings (
    booking_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guest_id       INTEGER        NOT NULL
                   REFERENCES guests(guest_id)
                   ON DELETE RESTRICT
                   ON UPDATE CASCADE,
    check_in_date  DATE           NOT NULL,
    check_out_date DATE           NOT NULL,
    total_amount   NUMERIC(10,2)  NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    status         VARCHAR(20)    NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'confirmed', 'checked_in', 'completed', 'cancelled')),
    CHECK (check_out_date > check_in_date)
);

-- Junction: Booking M:N Room
CREATE TABLE booking_rooms (
    booking_id  INTEGER      NOT NULL
                REFERENCES bookings(booking_id)
                ON DELETE CASCADE
                ON UPDATE CASCADE,
    hotel_id    INTEGER      NOT NULL,
    room_number VARCHAR(10)  NOT NULL,
    stay_from   DATE         NOT NULL,
    stay_to     DATE         NOT NULL,
    PRIMARY KEY (booking_id, hotel_id, room_number),
    FOREIGN KEY (hotel_id, room_number)
        REFERENCES rooms(hotel_id, room_number)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (stay_to > stay_from)
);

-- Junction: Booking M:N Service
CREATE TABLE booking_services (
    booking_id INTEGER  NOT NULL
               REFERENCES bookings(booking_id)
               ON DELETE CASCADE
               ON UPDATE CASCADE,
    service_id INTEGER  NOT NULL
               REFERENCES services(service_id)
               ON DELETE RESTRICT
               ON UPDATE CASCADE,
    date_used  DATE     NOT NULL,
    quantity   INTEGER  NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (booking_id, service_id, date_used)
);