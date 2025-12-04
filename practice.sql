CREATE TABLE hotels (
 hotel_id SERIAL PRIMARY KEY,
 hotel_name VARCHAR(100),
 city VARCHAR(50),
 star_rating INTEGER,
 total_rooms INTEGER,
 description TEXT
);
-- Insert sample data
INSERT INTO hotels (hotel_name, city, star_rating, total_rooms, description) VALUES
('Rixos Almaty', 'Almaty', 5, 120, 'Luxury hotel in the heart of Almaty'),
('The Ritz-Carlton Astana', 'Astana', 5, 157, 'Five-star luxury in the capital'),
('Dostyk Hotel', 'Almaty', 4, 85, 'Business hotel near Dostyk Avenue'),
('Kazzhol Hotel', 'Almaty', 3, 65, 'Comfortable and affordable accommodation'),
('Hilton Garden Inn', 'Astana', 4, 95, 'Modern hotel with excellent service'),
('Grand Park Esil', 'Astana', 3, 72, 'Central location, great value'),
('Shymkent Plaza', 'Shymkent', 4, 80, 'Premier hotel in South Kazakhstan'),
('Karaganda Hotel', 'Karaganda', 3, 55, 'Classic hotel in city center');
-- Create room_types table
CREATE TABLE room_types (
 room_type_id SERIAL PRIMARY KEY,
 hotel_id INTEGER REFERENCES hotels(hotel_id),
 type_name VARCHAR(50),
 capacity INTEGER,
 base_price_per_night NUMERIC(10,2),
 available_rooms INTEGER
);
-- Insert sample data
INSERT INTO room_types (hotel_id, type_name, capacity, base_price_per_night, available_rooms)
VALUES
(1, 'Standard', 2, 65000, 40),
(1, 'Deluxe', 2, 95000, 35),
(1, 'Suite', 4, 180000, 20),
(1, 'Presidential Suite', 6, 450000, 5),
(2, 'Standard', 2, 75000, 50),
(2, 'Executive', 2, 110000, 40),
(2, 'Suite', 4, 220000, 25),
(3, 'Standard', 2, 35000, 40),
(3, 'Business', 2, 52000, 30),
(3, 'Suite', 3, 85000, 15),
(4, 'Economy', 2, 18000, 35),
(4, 'Standard', 2, 28000, 30),
(5, 'Standard', 2, 42000, 45),
(5, 'Deluxe', 2, 68000, 30),
(5, 'Suite', 4, 125000, 20),
(6, 'Standard', 2, 25000, 40),
(6, 'Comfort', 2, 38000, 32),
(7, 'Standard', 2, 38000, 45),
(7, 'Suite', 3, 72000, 20),
(8, 'Standard', 2, 22000, 35),
(8, 'Deluxe', 2, 35000, 20);
-- Create guests table
CREATE TABLE guests (
 guest_id SERIAL PRIMARY KEY,
 full_name VARCHAR(100),
 email VARCHAR(100),
 phone VARCHAR(20),
 nationality VARCHAR(50),
 loyalty_status VARCHAR(20),
 total_bookings INTEGER,
 registration_date DATE
);
INSERT INTO guests (full_name, email, phone, nationality, loyalty_status, total_bookings,
registration_date) VALUES
('Айдар Сұлтанов', 'aidar.s@mail.kz', '+77011234567', 'Kazakhstan', 'gold', 12, '2022-03-15'),
('Марина Ковалева', 'marina.k@gmail.com', '+77012345678', 'Russia', 'platinum', 25,
'2021-06-20'),
('Жандос Әбілов', 'zhandos.a@inbox.kz', '+77023456789', 'Kazakhstan', 'silver', 6, '2023-01-10'),
('Elena Schmidt', 'elena.s@email.com', '+491234567890', 'Germany', 'bronze', 3, '2023-05-22'),
('Нұрболат Қаржаубаев', 'nurbolat.k@mail.kz', '+77045678901', 'Kazakhstan', 'gold', 15,
'2022-08-05'),
('Li Wei', 'li.wei@mail.cn', '+861234567890', 'China', 'silver', 8, '2023-02-18'),
('Сара Төлепова', 'sara.t@gmail.com', '+77067890123', 'Kazakhstan', 'bronze', 4, '2023-06-30'),
('Ahmed Al-Rashid', 'ahmed.a@email.ae', '+971234567890', 'UAE', 'platinum', 20, '2021-11-12');
-- Create bookings table
DROP  TABLE bookings CASCADE;
CREATE TABLE bookings (
 booking_id SERIAL PRIMARY KEY,
 guest_id INTEGER REFERENCES guests(guest_id),
 room_type_id INTEGER REFERENCES room_types(room_type_id),
 check_in_date DATE,
 check_out_date DATE,
 num_guests INTEGER,
 total_nights INTEGER,
 base_amount NUMERIC(12,2),
discount_amount NUMERIC(10,2),
 total_amount NUMERIC(12,2),
 booking_date TIMESTAMP,
 status VARCHAR(20),
 special_requests TEXT
);
-- Insert sample data
INSERT INTO bookings (guest_id, room_type_id, check_in_date, check_out_date, num_guests,
total_nights, base_amount, discount_amount, total_amount, booking_date, status, special_requests)
VALUES
(1, 2, '2024-12-01', '2024-12-05', 2, 4, 380000, 38000, 342000, '2024-11-15 10:30:00', 'confirmed',
'Late check-in'),
(2, 7, '2024-11-20', '2024-11-25', 3, 5, 1100000, 165000, 935000, '2024-11-01 14:20:00', 'checkedin', 'Non-smoking room'),
(3, 8, '2024-11-25', '2024-11-28', 2, 3, 105000, 5250, 99750, '2024-11-10 09:15:00', 'confirmed',
NULL),
(4, 13, '2024-12-10', '2024-12-15', 2, 5, 210000, 0, 210000, '2024-11-18 16:45:00', 'confirmed',
'Twin beds preferred'),
(5, 3, '2024-11-28', '2024-12-02', 4, 4, 720000, 72000, 648000, '2024-11-12 11:00:00', 'confirmed',
'High floor requested'),
(6, 14, '2024-12-05', '2024-12-08', 2, 3, 204000, 10200, 193800, '2024-11-20 13:30:00', 'confirmed',
NULL),
(7, 11, '2024-11-22', '2024-11-24', 2, 2, 36000, 0, 36000, '2024-11-15 15:45:00', 'confirmed', 'Extra
pillows'),
(8, 5, '2024-12-15', '2024-12-20', 2, 5, 375000, 56250, 318750, '2024-11-10 12:20:00', 'confirmed',
'Airport transfer needed'),
(1, 1, '2024-11-18', '2024-11-20', 2, 2, 130000, 13000, 117000, '2024-11-05 09:30:00', 'checked-out',
NULL),
(3, 9, '2024-11-10', '2024-11-13', 2, 3, 156000, 7800, 148200, '2024-10-28 14:00:00', 'checked-out',
NULL);
-- Create services table
CREATE TABLE services (
 service_id SERIAL PRIMARY KEY,
 service_name VARCHAR(100),
 service_category VARCHAR(50),
 price NUMERIC(10,2),
 description TEXT
);
-- Insert sample data
INSERT INTO services (service_name, service_category, price, description) VALUES
('Airport Transfer', 'Transportation', 15000, 'One-way transfer from/to airport'),
('Breakfast Buffet', 'Dining', 8000, 'Full breakfast buffet per person'),
('Spa Treatment - 60min', 'Wellness', 25000, 'Relaxing spa session'),
('Late Checkout', 'Hotel Service', 12000, 'Checkout after 12:00 PM'),
('Extra Bed', 'Room Service', 10000, 'Additional bed in room'),
('Laundry Service', 'Hotel Service', 5000, 'Express laundry per item'),
('Meeting Room - 2hr', 'Business', 35000, 'Conference room rental'),
('City Tour', 'Activities', 45000, 'Half-day guided city tour');
-- Create booking_services table
CREATE TABLE booking_services (
 booking_service_id SERIAL PRIMARY KEY,
 booking_id INTEGER REFERENCES bookings(booking_id),
 service_id INTEGER REFERENCES services(service_id),
 quantity INTEGER,
 service_date DATE,
 total_price NUMERIC(10,2)
);
-- Insert sample data
INSERT INTO booking_services (booking_id, service_id, quantity, service_date, total_price)
VALUES
(1, 1, 1, '2024-12-01', 15000),
(1, 2, 8, '2024-12-02', 64000),
(2, 2, 15, '2024-11-21', 120000),
(2, 3, 2, '2024-11-22', 50000),
(2, 8, 3, '2024-11-23', 135000),
(5, 1, 1, '2024-11-28', 15000),
(5, 5, 1, '2024-11-29', 10000),
(8, 1, 1, '2024-12-15', 15000),
(8, 2, 10, '2024-12-16', 80000);
-- Create reviews table
CREATE TABLE reviews (
 review_id SERIAL PRIMARY KEY,
 booking_id INTEGER REFERENCES bookings(booking_id),
 rating INTEGER,
 cleanliness_rating INTEGER,
 service_rating INTEGER,
 location_rating INTEGER,
 review_text TEXT,
 review_date DATE
);
-- Insert sample data
INSERT INTO reviews (booking_id, rating, cleanliness_rating, service_rating, location_rating,
review_text, review_date) VALUES
(9, 5, 5, 5, 5, 'Отличный сервис! Номер был безупречно чистым.', '2024-11-21'),
(10, 4, 4, 4, 5, 'Хорошее расположение, но завтрак мог быть лучше.', '2024-11-14');


CREATE OR REPLACE FUNCTION  calculate_room_rate(
    base_price NUMERIC,
    check_in_date DATE,
    num_nights INTEGER,
    season_type VARCHAR DEFAULT 'regular'
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    season_multiplier NUMERIC := CASE season_type
                                                WHEN 'high' THEN 1.5
                                                WHEN 'low' THEN 0.75
                                                ELSE 1.0
                                            END;
BEGIN
    SELECT COUNT(*)
    INTO weekend_nights
    FROM generate_series(check_in_date, check_in_date + num_nights - 1, INTERVAL '1 day') AS d
    WHERE EXTRACT(DOW FROM d) IN (5,6);
    RETURN base_price * num_nights * season_multiplier * (1 + 0.2 * weekend_nights / num_nights);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  calculate_loyalty_discount(
    total_amount NUMERIC,
    loyalty_status VARCHAR,
    total_bookings INTEGER
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    base_discount NUMERIC := 0;
    booking_bonus NUMERIC := 0;
    discount NUMERIC := 0;
BEGIN
    CASE LOWER(loyalty_status)
        WHEN 'bronze' THEN base_discount := 5;
        WHEN 'silver' THEN base_discount := 10;
        WHEN 'gold' THEN base_discount := 15;
        WHEN 'platinum' THEN base_discount := 20;
    END CASE;


