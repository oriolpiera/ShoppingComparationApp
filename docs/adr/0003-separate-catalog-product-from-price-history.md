# Separate Catalog Product from price history

The domain will stop treating a product identity and a supermarket price snapshot as the same thing. We will model a stable **Catalog Product** shared across supermarkets, identified by barcode when available or otherwise by Product Family plus normalized name, package quantity, and unit; supermarket-specific history will be stored as **Price Records** instead. This replaces the current `ProductItem + isCurrentPrice` rollover mental model and keeps price changes from creating fake new product identities.
