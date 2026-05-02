-- Contoso Retail Database Schema
-- Analytics project schema — no FK constraints by design.
-- This is an analytical database, not a transactional one.
-- Data integrity is validated at the Python/SQL analysis layer.


-- CURRENCY EXCHANGE Table
CREATE TABLE currency_exchange (
    Date             DATE,
    FromCurrency     VARCHAR(10),
    ToCurrency       VARCHAR(10),
    Exchange         NUMERIC(12,6)
);


-- CUSTOMER Table
CREATE TABLE customer (
    CustomerKey      INTEGER,
    GeoAreaKey       INTEGER,
    StartDT          DATE,
    EndDT            DATE,
    Continent        VARCHAR(50),
    Gender           VARCHAR(20),
    Title            VARCHAR(20),
    GivenName        VARCHAR(100),
    MiddleInitial    VARCHAR(10),
    Surname          VARCHAR(100),
    StreetAddress    VARCHAR(255),
    City             VARCHAR(100),
    State            VARCHAR(100),
    StateFull        VARCHAR(100),
    ZipCode          VARCHAR(20),
    Country          VARCHAR(50),
    CountryFull      VARCHAR(100),
    Birthday         DATE,
    Age              INTEGER,
    Occupation       VARCHAR(100),
    Company          VARCHAR(100),
    Vehicle          VARCHAR(150),
    Latitude         NUMERIC(10,6),
    Longitude        NUMERIC(10,6)
);


-- DATE DIMENSION Table
CREATE TABLE date_dim (
    Date                 DATE,
    DateKey              INTEGER,
    Year                 INTEGER,
    YearQuarter          VARCHAR(20),
    YearQuarterNumber    INTEGER,
    Quarter              VARCHAR(20),
    YearMonth            VARCHAR(20),
    YearMonthShort       VARCHAR(20),
    YearMonthNumber      INTEGER,
    Month                VARCHAR(20),
    MonthShort           VARCHAR(20),
    MonthNumber          INTEGER,
    DayofWeek            VARCHAR(20),
    DayofWeekShort       VARCHAR(20),
    DayofWeekNumber      INTEGER,
    WorkingDay           INTEGER,
    WorkingDayNumber     INTEGER
);


-- ORDERS Table
CREATE TABLE orders (
    OrderKey         INTEGER,
    CustomerKey      INTEGER,
    StoreKey         INTEGER,
    OrderDate        DATE,
    DeliveryDate     DATE,
    CurrencyCode     VARCHAR(10)
);


-- ORDER ROWS Table
CREATE TABLE orderrows (
    OrderKey         INTEGER,
    LineNumber       INTEGER,
    ProductKey       INTEGER,
    Quantity         INTEGER,
    UnitPrice        NUMERIC(12,2),
    NetPrice         NUMERIC(12,2),
    UnitCost         NUMERIC(12,2)
);


-- PRODUCT Table
CREATE TABLE product (
    ProductKey       INTEGER,
    ProductCode      INTEGER,
    ProductName      VARCHAR(255),
    Manufacturer     VARCHAR(255),
    Brand            VARCHAR(255),
    Color            VARCHAR(50),
    WeightUnit       VARCHAR(20),
    Weight           NUMERIC(10,2),
    Cost             NUMERIC(12,2),
    Price            NUMERIC(12,2),
    CategoryKey      INTEGER,
    CategoryName     VARCHAR(100),
    SubCategoryKey   INTEGER,
    SubCategoryName  VARCHAR(100)
);


-- STORE Table
CREATE TABLE store (
    StoreKey         INTEGER,
    StoreCode        INTEGER,
    GeoAreaKey       INTEGER,
    CountryCode      VARCHAR(10),
    CountryName      VARCHAR(100),
    State            VARCHAR(100),
    OpenDate         DATE,
    CloseDate        DATE,
    Description      VARCHAR(255),
    SquareMeters     NUMERIC(10,2),
    Status           VARCHAR(50)
);