-- Keep a log of any SQL queries you execute as you solve the mystery.


-- Description of crime from crime_scene_report: "Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery.
-- Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.
-- Littering took place at 16:36. No known witnesses."
SELECT description FROM crime_scene_reports
WHERE year = 2021
AND month = 7
AND day = 28
AND street = 'Humphrey Street';


-- Interviews have been checked:
-- Ruth: "Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame."
-- Eugene: "I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money."
-- Raymond: "As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket."
SELECT * FROM interviews
WHERE year = 2021
AND month = 7
AND day = 28;


-- License_plates and whom belong is checked from bakery_security_log which vehicles left within 10 minutes of the theft:
SELECT name,id,license_plate
FROM people WHERE license_plate IN
    (SELECT license_plate FROM bakery_security_logs
    WHERE year=2021
    AND month=7
    AND day=28
    AND hour=10
    AND minute >= 15
    AND minute <= 25
    AND activity ='exit');
-- SELECT name,id,license_plate FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE year=2021 AND month=7 AND day=28 AND hour=10 AND minute >= 15 AND minute <= 25 AND activity ='exit');


-- In order to determine ATM time arrival time of Eugene to bakery is checked: Not came to bakery by car on theft date.
-- ATM transactions is checked upon Eugene assertion:
SELECT account_number,amount,transaction_type
FROM atm_transactions
WHERE year=2021
AND month=7
AND day=28
AND atm_location='Leggett Street'
AND transaction_type LIKE 'withdraw';
-- SELECT account_number,amount,transaction_type FROM atm_transactions WHERE year=2021 AND month=7 AND day=28 AND atm_location='Leggett Street' AND transaction_type LIKE 'withdraw';


-- Intersection of people id left within 10 min & atm withdrawal: Iman, Luca, Diana, Bruce
SELECT name FROM people
WHERE people.id IN
    (SELECT person_id FROM bank_accounts
    JOIN atm_transactions
    ON bank_accounts.account_number=atm_transactions.account_number
    WHERE atm_transactions.account_number IN
        (SELECT account_number FROM atm_transactions
        WHERE year=2021
        AND month=7
        AND day=28
        AND atm_location='Leggett Street'
        AND transaction_type LIKE 'withdraw'))
    AND id IN (SELECT id FROM people
    WHERE license_plate IN
        (SELECT license_plate FROM bakery_security_logs
        WHERE year=2021
        AND month=7
        AND day=28
        AND hour=10
        AND minute >= 15
        AND minute <= 25
        AND activity ='exit'));
-- SELECT name FROM people WHERE people.id IN (SELECT person_id FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number=atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE year=2021 AND month=7 AND day=28 AND atm_location='Leggett Street' AND transaction_type LIKE 'withdraw')) AND id IN (SELECT id FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE year=2021 AND month=7 AND day=28 AND hour=10 AND minute >= 15 AND minute <= 25 AND activity ='exit'));


-- Who called whom is checked: callers; Diana and Bruce.
SELECT name FROM people
WHERE phone_number IN
    (SELECT caller FROM phone_calls
    WHERE year=2021
    AND month=7
    AND day=28
    AND duration < 60)
AND name IN
    (SELECT name FROM people
    WHERE people.id IN
        (SELECT person_id FROM bank_accounts
        JOIN atm_transactions
        ON bank_accounts.account_number=atm_transactions.account_number
        WHERE atm_transactions.account_number IN
            (SELECT account_number FROM atm_transactions
            WHERE year=2021
            AND month=7
            AND day=28
            AND atm_location='Leggett Street'
            AND transaction_type LIKE 'withdraw'))
        AND id IN
            (SELECT id FROM people
            WHERE license_plate IN
                (SELECT license_plate FROM bakery_security_logs
                WHERE year=2021
                AND month=7
                AND day=28
                AND hour=10
                AND minute >= 15
                AND minute <= 25
                AND activity ='exit')));
-- SELECT name FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE year=2021 AND month=7 AND day=28 AND duration < 60) AND name IN (SELECT name FROM people WHERE people.id IN (SELECT person_id FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number=atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE year=2021 AND month=7 AND day=28 AND atm_location='Leggett Street' AND transaction_type LIKE 'withdraw')) AND id IN (SELECT id FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE year=2021 AND month=7 AND day=28 AND hour=10 AND minute >= 15 AND minute <= 25 AND activity ='exit')));


-- Whom Bruce called: receivers; Robin
SELECT name FROM people
WHERE phone_number IN
    (SELECT receiver FROM phone_calls
    WHERE year=2021
    AND month=7
    AND day=28
    AND duration < 60
    AND caller=
        (SELECT phone_number FROM people
        WHERE name='Bruce'));
-- SELECT name FROM people WHERE phone_number IN (SELECT receiver FROM phone_calls WHERE year=2021 AND month=7 AND day=28 AND duration < 60 AND caller=(SELECT phone_number FROM people WHERE name='Bruce'));


-- Tomorrow early flights from Fiftyville: New York City (flight no 36 at 8 am) or Chicago (flight no 43 at 9 am)
SELECT flights.id,airports.city,flights.hour FROM flights
JOIN airports ON flights.destination_airport_id=airports.id
WHERE year=2021
AND month=7
AND day=29
AND hour < 12
AND origin_airport_id =
    (SELECT id FROM airports WHERE city = 'Fiftyville');
-- SELECT flights.id,airports.city,flights.hour FROM flights JOIN airports ON flights.destination_airport_id=airports.id WHERE year=2021 AND month=7 AND day=29 AND hour < 12 AND origin_airport_id = (SELECT id FROM airports WHERE city = 'Fiftyville');


-- Passenger check to earliest flight from Fiftyville to New York: Bruce
-- Intersection of whole datas collected: Bruce
SELECT name FROM people
WHERE passport_number IN
    (SELECT passport_number FROM passengers
    WHERE flight_id =
        (SELECT flights.id FROM flights
        JOIN airports ON flights.destination_airport_id=airports.id
        WHERE year=2021
        AND month=7
        AND day=29
        AND hour < 12
        AND origin_airport_id =
            (SELECT id FROM airports WHERE city = 'Fiftyville')))
AND name IN
    (SELECT name FROM people
    WHERE phone_number IN
        (SELECT caller FROM phone_calls
        WHERE year=2021
        AND month=7
        AND day=28
        AND duration < 60)
        AND name IN
            (SELECT name FROM people
            WHERE people.id IN
                (SELECT person_id FROM bank_accounts
                JOIN atm_transactions ON bank_accounts.account_number=atm_transactions.account_number
                WHERE atm_transactions.account_number IN
                    (SELECT account_number FROM atm_transactions
                    WHERE year=2021
                    AND month=7
                    AND day=28
                    AND atm_location='Leggett Street'
                    AND transaction_type LIKE 'withdraw'))
AND id IN
    (SELECT id FROM people
    WHERE license_plate IN
        (SELECT license_plate FROM bakery_security_logs
        WHERE year=2021
        AND month=7
        AND day=28
        AND hour=10
        AND minute >= 15
        AND minute <= 25
        AND activity ='exit'))));
-- SELECT name FROM people WHERE passport_number IN (SELECT passport_number FROM passengers WHERE flight_id = (SELECT flights.id FROM flights JOIN airports ON flights.destination_airport_id=airports.id WHERE year=2021 AND month=7 AND day=29 AND hour < 12 AND origin_airport_id = (SELECT id FROM airports WHERE city = 'Fiftyville'))) AND name IN (SELECT name FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE year=2021 AND month=7 AND day=28 AND duration < 60) AND name IN (SELECT name FROM people WHERE people.id IN (SELECT person_id FROM bank_accounts JOIN atm_transactions ON bank_accounts.account_number=atm_transactions.account_number WHERE atm_transactions.account_number IN (SELECT account_number FROM atm_transactions WHERE year=2021 AND month=7 AND day=28 AND atm_location='Leggett Street' AND transaction_type LIKE 'withdraw')) AND id IN (SELECT id FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE year=2021 AND month=7 AND day=28 AND hour=10 AND minute >= 15 AND minute <= 25 AND activity ='exit'))));

