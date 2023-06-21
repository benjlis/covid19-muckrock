create table if not exists covid19_muckrock.pii_types 
    (pii_types text primary key,
     description text not null);
insert into covid19_muckrock.pii_types values
    ('ban', 'Bank account number, 10-18 digits'),
    ('credit_card', 'Credit card number'),
    ('drivers_license', 'Drivers license'),
    ('ssn','Social security number'),
    ('phone_number','Phone number'),
    ('email_address','Email address'),
    ('street_address','Street address'),
    ('zipcode', 'Zipcode'),
    ('name', 'Name of non-public figure');