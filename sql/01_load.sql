COPY currency_exchange FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/currencyexchange.csv' DELIMITER ',' CSV HEADER;

COPY customer FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/customer.csv' DELIMITER ',' CSV HEADER;

COPY date_dim FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/date.csv' DELIMITER ',' CSV HEADER;

COPY orders FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/orders.csv' DELIMITER ',' CSV HEADER;

COPY orderrows FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/orderrows.csv' DELIMITER ',' CSV HEADER;

COPY product FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/product.csv' DELIMITER ',' CSV HEADER;

COPY store FROM 'D:/data-analysis-projects/retail-discount-profitability-audit/data/raw/store.csv' DELIMITER ',' CSV HEADER;